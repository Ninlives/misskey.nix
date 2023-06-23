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
    rev = "7093662ce5c17a8096c33712d0056de9fd4b5a41";
    sha256 = "sha256-rFowRU8wJHx1uCs68cpY5wxTsioLtzgzfpgZZzE2A5I=";
  };
  patches = [ ./config_files_dir_env.patch ./relay.patch ];
  lockOverride.packages = {
    "github.com/misskey-dev/browser-image-resizer/0227e860621e55cbed0aabe6dc601096a7748c4a".resolution.integrity = "sha512-g/obrtD0QNgDQEYw9R+Pdyw9GtGYCbAh5y6XG/TXyShCHP62o8hzQsSJ+VDRp2/qPLWCxApyJA/IpQ6dOncA2g==";    
    "github.com/misskey-dev/buraha/92b20c1ab15c5cb5a224cf3b1ecd4f6baca12b7c".resolution.integrity = "sha512-TDkaeS+H6xj9S2FtTosQoVweEjtF+CqNjwMdn+y9SWaz5+7HgahtCVFFTN/ltvx8jJd5lMcgAik/WxFSkCG9jw==";
    "github.com/misskey-dev/sharp-read-bmp/02d9dc189fa7df0c4bea09330be26741772dac01".resolution.integrity = "sha512-uv9YdN1KS6queU2iY+RMS3U2IhCSn/zDDoZBqzUp1SmJNnCgynfrguiilYkric/aJx7yBKjuDYUEipNsQ1ePBw==";
    "github.com/misskey-dev/storybook-addon-misskey-theme/cf583db098365b2ccc81a82f63ca9c93bc32b640(@storybook/blocks@7.0.18)(@storybook/components@7.0.18)(@storybook/core-events@7.0.18)(@storybook/manager-api@7.0.18)(@storybook/preview-api@7.0.18)(@storybook/theming@7.0.18)(@storybook/types@7.0.18)(react-dom@18.2.0)(react@18.2.0)".resolution.integrity = "sha512-QaH1uZSlApQ2CZPkHfhmNm89I92L02s3MdbUPG66TmAyqMaqzxd/AvobORBjtTZ0ymUSa3ii482dRXi+fFb19w==";
    "github.com/misskey-dev/summaly/77dd5654bb82280b38c1f50e51a771c33f3df503".resolution.integrity = "sha512-j7pj7nkEwiYQbveiwV7WDZ9WcB++e58vKlsAlpRS16sFqt47pxgHDmmrY48cEOI+qUOeDKipG9f6lYSOxnruqA==";
  };
  extraBuildInputs = [ vips ];

  installPhase = lib.concatMapStringsSep "\n" (p: ''
    mkdir -p "$out/${dirOf p}" 
    mv -v "${p}" "$out/${p}"
  '') installedPaths;
}
