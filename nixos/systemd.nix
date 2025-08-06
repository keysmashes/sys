{
  # it is incomprehensible that StatusUnitFormat=combined is not the default
  boot.initrd.systemd.settings.Manager = {
    StatusUnitFormat = "combined";
  };
}
