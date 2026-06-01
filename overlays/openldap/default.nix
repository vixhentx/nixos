{ ... }:
final: prev: {
  openldap = prev.openldap.overrideAttrs (old: {
    doCheck = false;
  });
}
