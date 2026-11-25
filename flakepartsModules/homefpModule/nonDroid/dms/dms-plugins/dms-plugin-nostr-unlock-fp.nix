{self, ...}: let
  mkAdminHelper = pkgs:
    pkgs.writeShellApplication {
      name = "dms-nostr-unlock-admin";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.getent
      ];
      text = ''
        action="''${1-}"
        user="''${2-}"
        state_base="/var/lib/dms-nostr-unlock"

        if [[ ! "$user" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
          echo "invalid username" >&2
          exit 2
        fi

        uid_line="$(getent passwd "$user" || true)"
        if [[ -z "$uid_line" ]]; then
          echo "unknown user" >&2
          exit 2
        fi
        IFS=: read -r _ _ target_uid _ <<< "$uid_line"

        # Enforce caller UID matches target user when elevated via pkexec/sudo/run0
        caller_uid="''${PKEXEC_UID:-''${SUDO_UID:-}}"
        if [[ -n "$caller_uid" ]]; then
          if [[ ! "$caller_uid" =~ ^[0-9]+$ ]] || [[ "$caller_uid" != "$target_uid" ]]; then
            echo "caller UID mismatch" >&2
            exit 3
          fi
        fi

        user_dir="$state_base/$user"
        anchor_file="$user_dir/trusted_pubkey"

        case "$action" in
          authorize)
            # Explicit step-1 authorization before pairing; writes nothing yet
            exit 0
            ;;
          register)
            raw_hex="''${3-}"
            pubkey="$(printf '%s' "$raw_hex" | tr 'A-F' 'a-f')"
            if [[ ! "$pubkey" =~ ^[0-9a-f]{64}$ ]]; then
              echo "invalid 64-char hex pubkey" >&2
              exit 2
            fi
            install -d -m 0755 -o root -g root "$state_base" "$user_dir"
            tmp_file=""
            trap 'rm -f "$tmp_file"' EXIT
            tmp_file="$(mktemp "$user_dir/.trusted_pubkey.XXXXXX")"
            chmod 0644 "$tmp_file"
            chown root:root "$tmp_file"
            printf '%s\n' "$pubkey" > "$tmp_file"
            mv -f "$tmp_file" "$anchor_file"
            tmp_file=""
            ;;
          revoke)
            rm -f -- "$anchor_file"
            ;;
          *)
            echo "usage: dms-nostr-unlock-admin <authorize|register|revoke> <user> [hex_pubkey]" >&2
            exit 2
            ;;
        esac
      '';
    };

  mkSignHelper = pkgs: amyPkg:
    pkgs.writeShellApplication {
      name = "dms-nostr-unlock-sign";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.jq
        pkgs.nak
        amyPkg
      ];
      text = ''
        account="dms-unlock"
        user="$(id -un)"
        anchor_file="/var/lib/dms-nostr-unlock/$user/trusted_pubkey"

        if [[ ! -f "$anchor_file" ]] || [[ -L "$anchor_file" ]] || [[ ! -r "$anchor_file" ]]; then
          echo "not paired (missing trust anchor)" >&2
          exit 1
        fi
        trusted_pubkey="$(head -c 128 "$anchor_file" | tr 'A-F' 'a-f' | tr -d '[:space:]')"
        if [[ ! "$trusted_pubkey" =~ ^[0-9a-f]{64}$ ]]; then
          echo "invalid trust anchor" >&2
          exit 1
        fi

        host="$(uname -n)"
        nonce="$(od -An -tx1 -N16 /dev/urandom | tr -d ' \n')"
        now="$(date +%s)"
        exp="$((now + 75))"
        tags_json="$(jq -nc --arg h "$host" --arg n "$nonce" --arg e "$exp" \
          '[["host",$h],["challenge",$n],["expiration",$e]]')"

        # Cap amy wait (Amethyst RemoteSignerManager defaults to ~130s across retry)
        signed_json="$(timeout 75s amy --account "$account" --secret-backend plaintext --json event \
          --kind 27235 --content "DMS unlock $host ($nonce)" --tags "$tags_json" </dev/null)"

        event_json="$(printf '%s\n' "$signed_json" | jq -c '.event')"
        if [[ -z "$event_json" ]] || [[ "$event_json" == "null" ]]; then
          echo "signer did not return event" >&2
          exit 1
        fi

        # Verify BIP-340 Schnorr signature and event id cryptographically
        printf '%s\n' "$event_json" | nak verify >/dev/null

        got_kind="$(printf '%s\n' "$event_json" | jq -r '.kind')"
        got_pubkey="$(printf '%s\n' "$event_json" | jq -r '.pubkey' | tr 'A-F' 'a-f')"
        got_nonce="$(printf '%s\n' "$event_json" | jq -r '([.tags[] | select(.[0]=="challenge") | .[1]] | first) // ""')"
        got_created="$(printf '%s\n' "$event_json" | jq -r '.created_at')"

        [[ "$got_kind" == "27235" ]]
        [[ "$got_pubkey" == "$trusted_pubkey" ]]
        [[ "$got_nonce" == "$nonce" ]]
        [[ "$got_created" =~ ^[0-9]+$ ]]
        verify_now="$(date +%s)"
        (( got_created >= now - 15 && got_created <= verify_now + 15 ))

        # Re-check anchor after network round-trip in case it was revoked while waiting
        [[ -f "$anchor_file" ]] && [[ ! -L "$anchor_file" ]] && [[ -r "$anchor_file" ]]
        recheck_pubkey="$(head -c 128 "$anchor_file" | tr 'A-F' 'a-f' | tr -d '[:space:]')"
        [[ "$recheck_pubkey" == "$trusted_pubkey" ]]
      '';
    };
in {
  flake.nixosModules.dms-plugin-nostr-unlock = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = [(mkAdminHelper pkgs)];
    security.polkit.enable = lib.mkDefault true;
    # nixpkgs disables setuid pkexec by default; adminHelper requires polkit elevation
    security.polkit.enablePkexecWrapper = lib.mkDefault true;
  };

  flake.homeModules.nonDroid.dms-plugin-nostr-unlock = {pkgs, ...}: let
    amyPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.amy;
  in {
    programs.dank-material-shell.plugins.nostrUnlock = {
      enable = true;
      src = ./dms-nostr-unlock;
    };

    dms.extraPackages = [
      (mkSignHelper pkgs amyPkg)
      amyPkg
      pkgs.nak
    ];
  };

  perSystem = {pkgs, ...}: let
    amyPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.amy;
    adminHelper = mkAdminHelper pkgs;
    signHelper = mkSignHelper pkgs amyPkg;
  in {
    checks.dms-nostr-unlock =
      pkgs.runCommand "dms-nostr-unlock-check" {
        nativeBuildInputs = [
          pkgs.bash
          pkgs.coreutils
          pkgs.getent
          pkgs.jq
          pkgs.nak
        ];
      } ''
        set -euo pipefail
        export HOME="$TMPDIR/home"
        u="$(id -un)"
        my_uid="$(id -u)"

        mkdir -p "$HOME" "$TMPDIR/bin" "$TMPDIR/stub-amy" "$TMPDIR/state"

        # Patch store paths into sandbox temp workspace without altering production logic
        substitute "${adminHelper}/bin/dms-nostr-unlock-admin" "$TMPDIR/bin/admin" \
          --replace-fail 'state_base="/var/lib/dms-nostr-unlock"' "state_base=\"$TMPDIR/state\"" \
          --replace-fail ' -o root -g root' "" \
          --replace-fail 'chown root:root "$tmp_file"' "true"
        chmod +x "$TMPDIR/bin/admin"

        substitute "${signHelper}/bin/dms-nostr-unlock-sign" "$TMPDIR/bin/sign" \
          --replace-fail 'anchor_file="/var/lib/dms-nostr-unlock/$user/trusted_pubkey"' "anchor_file=\"$TMPDIR/state/\$user/trusted_pubkey\"" \
          --replace-fail "${amyPkg}/bin" "$TMPDIR/stub-amy"
        chmod +x "$TMPDIR/bin/sign"

        # Admin validation checks
        ! "$TMPDIR/bin/admin" authorize "../root"
        ! "$TMPDIR/bin/admin" authorize "nosuchuser_123"
        ! PKEXEC_UID=999999 "$TMPDIR/bin/admin" authorize "$u"
        ! PKEXEC_UID=abc "$TMPDIR/bin/admin" authorize "$u"
        ! PKEXEC_UID="$my_uid" "$TMPDIR/bin/admin" register "$u" "not-hex"
        ! PKEXEC_UID="$my_uid" "$TMPDIR/bin/admin" bogus "$u"

        PKEXEC_UID="$my_uid" "$TMPDIR/bin/admin" authorize "$u"
        test ! -e "$TMPDIR/state/$u/trusted_pubkey"

        trusted_sec="$(nak key generate)"
        trusted_pub="$(nak key public "$trusted_sec")"
        trusted_upper="$(printf '%s' "$trusted_pub" | tr 'a-f' 'A-F')"
        other_sec="$(nak key generate)"

        # Sign fails when unpaired
        ! "$TMPDIR/bin/sign"

        # Register normalizes uppercase hex and sets 0644
        PKEXEC_UID="$my_uid" "$TMPDIR/bin/admin" register "$u" "$trusted_upper"
        test "$(cat "$TMPDIR/state/$u/trusted_pubkey")" = "$trusted_pub"
        test "$(stat -c %a "$TMPDIR/state/$u/trusted_pubkey")" = "644"

        # Configurable stub amy replacing only remote network signing
        cat > "$TMPDIR/stub-amy/amy" <<'STUB'
        #!${pkgs.bash}/bin/bash
        set -euo pipefail
        tags=""
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --tags) tags="$2"; shift 2 ;;
            *) shift ;;
          esac
        done
        nonce="$(printf '%s' "$tags" | jq -r '([.[] | select(.[0]=="challenge") | .[1]] | first) // ""')"
        case "''${STUB_MODE:-valid}" in
          valid)
            ev="$(nak event --sec "$STUB_SEC" -k 27235 -c "unlock" -t "challenge=$nonce" </dev/null)"
            ;;
          wrong_nonce)
            ev="$(nak event --sec "$STUB_SEC" -k 27235 -c "unlock" -t "challenge=00000000000000000000000000000000" </dev/null)"
            ;;
          bad_sig)
            ev="$(nak event --sec "$STUB_SEC" -k 27235 -c "unlock" -t "challenge=$nonce" </dev/null | jq -c '.sig = ("0" * 128)')"
            ;;
          stale)
            ev="$(nak event --sec "$STUB_SEC" -k 27235 --ts "$(( $(date +%s) - 600 ))" -c "unlock" -t "challenge=$nonce" </dev/null)"
            ;;
          revoke_midflight)
            ev="$(nak event --sec "$STUB_SEC" -k 27235 -c "unlock" -t "challenge=$nonce" </dev/null)"
            PKEXEC_UID="$STUB_UID" "$STUB_ADMIN" revoke "$STUB_USER"
            ;;
          slow)
            sleep 2
            ev="$(nak event --sec "$STUB_SEC" -k 27235 -c "unlock" -t "challenge=$nonce" </dev/null)"
            ;;
        esac
        jq -nc --argjson e "$ev" '{event: $e, published: false}'
        STUB
        chmod +x "$TMPDIR/stub-amy/amy"

        export STUB_ADMIN="$TMPDIR/bin/admin" STUB_USER="$u" STUB_UID="$my_uid"

        # Valid signature passes
        STUB_MODE=valid STUB_SEC="$trusted_sec" "$TMPDIR/bin/sign"

        # Untrusted signer pubkey fails
        ! STUB_MODE=valid STUB_SEC="$other_sec" "$TMPDIR/bin/sign"

        # Replayed / mismatched challenge fails
        ! STUB_MODE=wrong_nonce STUB_SEC="$trusted_sec" "$TMPDIR/bin/sign"

        # Tampered BIP-340 signature caught by nak verify
        ! STUB_MODE=bad_sig STUB_SEC="$trusted_sec" "$TMPDIR/bin/sign"

        # Stale timestamp fails
        ! STUB_MODE=stale STUB_SEC="$trusted_sec" "$TMPDIR/bin/sign"

        # Anchor revoked while signer prompt was in flight fails
        ! STUB_MODE=revoke_midflight STUB_SEC="$trusted_sec" "$TMPDIR/bin/sign"
        test ! -e "$TMPDIR/state/$u/trusted_pubkey"

        # Re-register and check bounded timeout exits cleanly on hang
        PKEXEC_UID="$my_uid" "$TMPDIR/bin/admin" register "$u" "$trusted_pub"
        substitute "$TMPDIR/bin/sign" "$TMPDIR/bin/sign-fast-timeout" \
          --replace-fail 'timeout 75s' 'timeout 1s'
        chmod +x "$TMPDIR/bin/sign-fast-timeout"
        ! STUB_MODE=slow STUB_SEC="$trusted_sec" "$TMPDIR/bin/sign-fast-timeout"

        touch "$out"
      '';
  };
}
