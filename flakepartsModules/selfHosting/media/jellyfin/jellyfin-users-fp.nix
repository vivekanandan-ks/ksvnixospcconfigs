{
  inputs,
  lib,
  ...
}: {
  flake.hostModules.ksvnixospc.jellyfin-users = lib.mkIf (inputs ? nixflix) {
    nixflix.jellyfin.users = {
      # Administrator Account
      admin = {
        mutable = false;
        policy = {
          isAdministrator = true;
          enableVideoPlaybackTranscoding = false; # Enforce 100% Direct Play
          enableAudioPlaybackTranscoding = false;
        };
        password = "admin123";
      };

      # Standard User Account (Restricted permissions)
      user = {
        mutable = false;
        policy = {
          isAdministrator = false;
          enableContentDeletion = false;     # Prevents accidental deletion of media files
          enableCollectionManagement = false;
          enableUserPreferenceAccess = false;
          enableVideoPlaybackTranscoding = false; # Enforce 100% Direct Play (client decodes)
          enableAudioPlaybackTranscoding = false;
        };
        password = "user123";
      };
    };
  };
}
