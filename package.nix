{ mkPnpmPackage, fetchFromGitHub, vips, lib }:
let
  installedPaths = [
   "assets"
   "built"
   "chart"
   "fluent-emojis"
   "locales"
   "misskey-assets"
   "COPYING"
   "LICENSE"
   "node_modules"
   ".node-version"
   "package.json"

   "packages/backend/assets"
   "packages/backend/built"
   "packages/backend/migration"
   "packages/backend/nsfw-model"
   "packages/backend/node_modules"
   "packages/backend/ormconfig.js"
   "packages/backend/check_connect.js"
   "packages/backend/package.json"

   "packages/frontend/assets"
   "packages/frontend/node_modules"

   "packages/misskey-js/built"
   "packages/misskey-js/LICENSE"
   "packages/misskey-js/node_modules"

   "packages/sw/node_modules"
  ];
in
mkPnpmPackage {
  src = fetchFromGitHub {
    owner = "misskey-dev";
    repo = "misskey";
    fetchSubmodules = true;
    rev = "a8d45d4b0d24e0c422d4e6d8feab57035239db56";
    sha256 = "sha256-M+O1pDn1gnpheY8f4PCsUdWCvJcXq4+XDXSJTQhZyAQ=";
  };
  patches = [ ./config_files_dir_env.patch ./build-log.patch ./fix_copy.patch ];
  lockOverride.packages = {
    "github.com/misskey-dev/browser-image-resizer/0227e860621e55cbed0aabe6dc601096a7748c4a".resolution.integrity = "sha512-g/obrtD0QNgDQEYw9R+Pdyw9GtGYCbAh5y6XG/TXyShCHP62o8hzQsSJ+VDRp2/qPLWCxApyJA/IpQ6dOncA2g==";    
    "github.com/misskey-dev/sharp-read-bmp/02d9dc189fa7df0c4bea09330be26741772dac01".resolution.integrity = "sha512-uv9YdN1KS6queU2iY+RMS3U2IhCSn/zDDoZBqzUp1SmJNnCgynfrguiilYkric/aJx7yBKjuDYUEipNsQ1ePBw==";
    "github.com/misskey-dev/storybook-addon-misskey-theme/cf583db098365b2ccc81a82f63ca9c93bc32b640(@storybook/blocks@7.0.27)(@storybook/components@7.1.0)(@storybook/core-events@7.0.27)(@storybook/manager-api@7.0.27)(@storybook/preview-api@7.0.27)(@storybook/theming@7.0.27)(@storybook/types@7.0.27)(react-dom@18.2.0)(react@18.2.0)".resolution.integrity = "sha512-QaH1uZSlApQ2CZPkHfhmNm89I92L02s3MdbUPG66TmAyqMaqzxd/AvobORBjtTZ0ymUSa3ii482dRXi+fFb19w==";
    "github.com/misskey-dev/summaly/089a0ad8e8c780e5c088b1c528aa95c5827cbdcc".resolution.integrity = "sha512-MXio3ndxVgVPmFblnWL8VliFrfww/rca33VhisLTrMk/zEC20x1eZKhloWE6qPBA8TK5ZfaAdMJij1MFTJMuAg==";
  };
  extraBuildInputs = [ vips ];

  postConfigure = ''
    for package in "backend" "frontend" "sw";do
      modules=$(readlink "packages/$package/node_modules")
      rm "packages/$package/node_modules"
      mkdir -p "packages/$package/node_modules"
      for module in $(find $modules/ -maxdepth 1);do
        if [[ $(basename "$module") == "misskey-js" ]];then
          continue
        fi
        ln -s "$module" "packages/$package/node_modules"
      done
      ln -s "../../misskey-js" "packages/$package/node_modules/misskey-js"
    done
  '';

  installPhase = lib.concatMapStringsSep "\n" (p: ''
    mkdir -p "$out/${dirOf p}" 
    mv -v "${p}" "$out/${p}"
  '') installedPaths;
}
