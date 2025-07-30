{ lib
, fetchFromGitHub
, rustPlatform
, stdenv
}:

rustPlatform.buildRustPackage {
  pname = "some";
  version = "unstable-2025-05-16";

  src = fetchFromGitHub {
    owner = "keysmashes";
    repo = "some.rs";
    rev = "caf66544e628edff4feb509ef555f0a3e9eeec9b";
    hash = "sha256-+B3tB9KZXCdI33Tdod+wjQ5WotL1rD8d0eLdpanG790=";
  };

  cargoHash = "sha256-5qe6E/5HkqZjpv1P7810/iFV+j4cdbpym1o5duee6/k=";
}
