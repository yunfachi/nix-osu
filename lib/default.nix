{ lib, delib, ... }:
delib.mkLib "self" (self: {
  generators.toOsuINI =
    let
      mkKeyValue =
        let
          mkValueString =
            v:
            let
              err =
                t: v:
                abort (
                  "generators.mkValueStringDefault: " + "${t} not supported: ${lib.generators.toPretty { } v}"
                );
            in
            if lib.isInt v then
              toString v
            else if lib.isDerivation v then
              toString v
            else if lib.isString v then
              v
            else if true == v then
              "True"
            else if false == v then
              "False"
            else if lib.isList v then
              err "lists" v
            else if lib.isAttrs v then
              err "attrsets" v
            else if lib.isFunction v then
              err "functions" v
            else if lib.isFloat v then
              lib.strings.floatToString v
            else
              err "this value is" (toString v);

        in
        k: v: "${lib.escape [ "=" ] k}=${mkValueString v}";

      mkLine = k: v: lib.optionalString (v != null) (mkKeyValue k v + "\n");
      mkLines = k: v: [ (mkLine k v) ];
    in
    attrs: lib.concatStrings (lib.concatLists (lib.mapAttrsToList mkLines attrs));
})
