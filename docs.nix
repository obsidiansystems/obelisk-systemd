# docs.nix
#
# Produce json and markdown documentation for nix module options.
# 
# Nix module options are defined sort of like this:
#
#    name = mkOption {
#      type = type specification;
#      default = default value;
#      example = example value;
#      description = "Description for use in the NixOS manual.";
#    };
#
# That information can be used to generate nice documentation pages for module
# users, and that's exactly what this nix expression does.
#
# For more on nix module options, see
# https://nixos.org/manual/nixos/stable/index.html#sec-option-declarations.

{ # The package set to build with. This is mostly used for library functions.
  pkgs ? import ./test/nixpkgs {}
  # The module to build documentation for.
, module ?  import ./system { config = {}; inherit pkgs; inherit (pkgs) lib; } 
}:
let inherit (pkgs) lib;
    # Check if an attrset contains an attr. If it does, return it. If it
    # doesn't return null.
    attrOrNull = x: a: if lib.hasAttr a x then x."${a}" else null;

    # Turns an options attrset into a description of those options that is
    # easily convertible to JSON. Usually, you'll call this with the "options"
    # attribute of some module. This will recurse into the sub-options of a
    # module.
    getOptions = a: lib.mapAttrs (k: v:
      let subopts = if lib.hasAttr "getSubOptions" v.type
            then v.type.getSubOptions {}
            else {};
      in if !(lib.isAttrs v) || !(lib.hasAttr "_type" v) then {} else
      { inherit (v) _type;
        type = {
          name = v.type.name;
          description = v.type.description;
        };
        description = attrOrNull v "description";
        example = attrOrNull v "example";
        default = attrOrNull v "default";
        suboptions = getOptions subopts;
    }) a;
    optionsDescription = getOptions module.options;

    # Turn a description of options into some markdown. The first argument,
    # "parent" is used to control how options are prefixed.
    # For example, given a module option structure like
    #    { optionA = { optionB = { optionC = string }; }; }
    # we want to generate three option descriptions:
    # * optionA
    # * optionA.optionB
    # * optionA.optionB.optionC
    generateMarkdown = parent: opts:
      let h = n: lib.concatMapStrings (_: "#") (lib.lists.range 1 n);
          p = if parent == null then "" else parent + ".";
          code = x: "`" + x + "`";
          showNicely = x: if lib.isAttrs x
            then if lib.hasAttr "_type" x && lib.lists.elem x._type ["literalExample" "literalExpression"]
              then "\n```\n" + x.text + "\n```"
              else code (builtins.toJSON x)
            else code (builtins.toJSON x);
      in
      lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: if !(lib.hasAttr "_type" v) then "" else ''
        ### `${p + k} :: ${v.type.description}`

        ${if v.description != null then "Description: ${v.description}" else ""}

        ${if v.default != null then "Default: " + showNicely v.default else ""}

        ${if v.example != null && v.example != {} then "Example: ${showNicely v.example}" else ""}

        ${generateMarkdown (if v.type.name == "attrsOf" then p + k + ".<name>" else p + k) v.suboptions}
      '') opts);
in { md = (generateMarkdown null optionsDescription);
     json = builtins.toJSON optionsDescription;
   }
