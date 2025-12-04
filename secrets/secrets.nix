let
  lithium = [ "age1ecmj8r0d3p336d93z320rrgs2gdsy9pxhatjevyx97806lz9yfyqf5784l" ];
in
{
  "lithium/authelia-config.age".publicKeys = lithium;
  "lithium/authelia-jwt.age".publicKeys = lithium;
  "lithium/authelia-storage.age".publicKeys = lithium;
  "lithium/authelia-oauth2.age".publicKeys = lithium;
  "lithium/authelia-oauth2-pub.age".publicKeys = lithium;
  "lithium/authelia-oauth2-hmac.age".publicKeys = lithium;
  "lithium/smtp.age".publicKeys = lithium;
}
