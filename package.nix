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
    rev = "3043b5256d7f9d9228035b0af9943027e0222dd4";
    sha256 = "sha256-PiJiY2fR/Fzp0mi75LnvVBXAdQrHYBxPLaZji2VWD30=";
  };
  patches = [ ./config_files_dir_env.patch ./build-log.patch ];
  lockOverride.packages = {
    "github.com/misskey-dev/browser-image-resizer/0227e860621e55cbed0aabe6dc601096a7748c4a".resolution.integrity = "sha512-g/obrtD0QNgDQEYw9R+Pdyw9GtGYCbAh5y6XG/TXyShCHP62o8hzQsSJ+VDRp2/qPLWCxApyJA/IpQ6dOncA2g==";    
    "github.com/misskey-dev/sharp-read-bmp/02d9dc189fa7df0c4bea09330be26741772dac01".resolution.integrity = "sha512-uv9YdN1KS6queU2iY+RMS3U2IhCSn/zDDoZBqzUp1SmJNnCgynfrguiilYkric/aJx7yBKjuDYUEipNsQ1ePBw==";
    "github.com/misskey-dev/storybook-addon-misskey-theme/cf583db098365b2ccc81a82f63ca9c93bc32b640(@storybook/blocks@7.5.1)(@storybook/components@7.5.0)(@storybook/core-events@7.5.1)(@storybook/manager-api@7.5.1)(@storybook/preview-api@7.5.1)(@storybook/theming@7.5.1)(@storybook/types@7.5.1)(react-dom@18.2.0)(react@18.2.0)".resolution.integrity = "sha512-QaH1uZSlApQ2CZPkHfhmNm89I92L02s3MdbUPG66TmAyqMaqzxd/AvobORBjtTZ0ymUSa3ii482dRXi+fFb19w==";
    "github.com/misskey-dev/summaly/d2d8db49943ccb201c1b1b283e9d0a630519fac7".resolution.integrity = "sha512-SSi5ofwer6a/jr5XiDUU94nGcRawQdd/uxunVSleFn6SgHd+GF3Zy9y6sSnM3qNWRM1CfVrFFuX4lAcyPH519A==";
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

  installPhase = ''
    runHook preInstall
    chmod -R u+w ./built
    ${lib.concatMapStringsSep "\n" (p: ''
      mkdir -p "$out/${dirOf p}" 
      mv -v "${p}" "$out/${p}"
    '') installedPaths}
    runHook postInstall
  '';
}
