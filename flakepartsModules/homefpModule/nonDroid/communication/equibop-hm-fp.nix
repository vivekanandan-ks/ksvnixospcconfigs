_: {
  flake.homeModules.nonDroid.equibop = {pkgs-unstable, ...}: {
    programs.equibop = {
      enable = true;
      package = pkgs-unstable.equibop;

      # Electron / Desktop settings
      settings = {
        discordBranch = "stable";
        minimizeToTray = "off";
        arRPC = "on";
        hardwareAcceleration = true;
      };

      # Equicord client mod & plugins
      equicord = {
        settings = {
          autoUpdate = false;
          notifyAboutUpdates = false;

          plugins = {
            # --- Core, Auditing & Stability ---
            MessageLogger.enabled = true;
            ShowHiddenChannels.enabled = true;
            PermissionsViewer.enabled = true;
            Experiments.enabled = true;
            CrashHandler.enabled = true;

            # --- Privacy & Tracking ---
            NoTrack.enabled = true;
            ClearURLs.enabled = true;

            # --- Media, Files & Zoom ---
            FileSplitter.enabled = true;
            ZipPreview.enabled = true;
            ImageZoom.enabled = true;
            FixImagesQuality.enabled = true;
            ReverseImageSearch.enabled = true;
            UnlockedAvatarZoom.enabled = true;

            # --- User Profiles & Identification ---
            PronounDB.enabled = true;
            ShowMeYourName.enabled = true;
            ShowConnections.enabled = true;
            PlatformIndicators.enabled = true;
            BetterSessions.enabled = true;
            MutualGroupDMs.enabled = true;
            ClickableRoles.enabled = true;
            BetterRoleDot.enabled = true;
            ForceOwnerCrown.enabled = true;
            ShowTimeouts.enabled = true;

            # --- Chat, Typing & Navigation UX ---
            TypingTweaks.enabled = true;
            MoreKaomoji.enabled = true;
            SearchReply.enabled = true;
            MessageLinkEmbed.enabled = true;
            PreviewMessage.enabled = true;
            CallTimer.enabled = true;
            OpenInApp.enabled = true;
            UserVoiceShow.enabled = true;
            MemberCount.enabled = true;
            PinDMs.enabled = true;
            ReadAllNotificationsButton.enabled = true;
            WhoReacted.enabled = true;
            FavoriteEmojiFirst.enabled = true;
            DisableCallIdle.enabled = true;
            GameActivityToggle.enabled = true;

            # --- Code Blocks ---
            ShikiCodeblocks.enabled = true;
            FixCodeblockGap.enabled = true;

            # --- Linux / Wayland Support ---
            WebScreenShareFixes.enabled = true;
          };
        };
      };
    };
  };
}
