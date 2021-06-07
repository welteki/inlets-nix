{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.inlets-server;
in
{
  options = {
    services.inlets-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Wether to enable the inlets server.
        '';
      };

      package = mkOption {
        type = types.path;
        default = pkgs.inlets;
        description = "The Inlets package.";
      };

      port = mkOption {
        type = types.int;
        default = 8000;
        description = ''
          Specifies the port for server and for tunnel.
        '';
      };

      token = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to file containing authentication token.
        '';
      };

      controlAddress = mkOption {
        options = {
          addr = mkOption {
            type = types.str;
            default = "0.0.0.0";
            description = ''
              Host address to listen to.
            '';
          };

          port = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = ''
              Port to listen to.
            '';
          };
        };
        default = { addr = "0.0.0.0"; port = null; };
        example = { addr = "0.0.0.0"; port = 8081; };
        description = ''
          Address and port tunnel clients should connect to.
          If port is not specified will listen on port specified by
          <literal>port</literal> option.
          NOTE: this will override default listening on all local addresses and port 8000.
        '';
      };

      dataAddress = mkOption {
        options = {
          addr = mkOption {
            type = types.str;
            default = "0.0.0.0";
            description = ''
              Host address to listen to.
            '';
          };

          port = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = ''
              Port to listen to.
            '';
          };
        };
        default = { addr = "0.0.0.0"; port = null; };
        example = { addr = "192.168.3.1"; port = 80; };
        description = ''
          Address and port the server should serve tunneled services on.
          If port is not specified will listen on port specified by
          <literal>port</literal> option.
          NOTE: this will override default listening on all local addresses and port 8000.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers.inlets = {
      description = "Inlets";
      isSystemUser = true;
      createHome = false;
    };

    systemd.services.inlets-server = {
      description = "Inlets Server Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;
        StartLimitInterval = 0;
        ExecStart = ''${cfg.package}/bin/inlets server \
          --port ${toString (if cfg.dataAddress.port != null then cfg.dataAddress.port else cfg.port)} \
          --data-addr ${cfg.dataAddress.addr} \
          --control-addr ${cfg.controlAddress.addr} \
          --control-port ${toString (if cfg.controlAddress.port != null then cfg.controlAddress.port else cfg.port)} \
          ${if cfg.token != null then "--token-from ${toString cfg.token}" else ""}
        '';
      };
    };
  };
}
