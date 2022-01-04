{ pkgs ? import ./test/nixpkgs {}
, module ?  import ./system { config = {}; inherit pkgs; inherit (pkgs) lib; } 
}:
let inherit (pkgs) lib;
    attrOrNull = x: a: if lib.hasAttr a x then x."${a}" else null;
    getOptions = a:
      lib.mapAttrs (k: v:
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
    options = getOptions module.options;
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
in { md = (generateMarkdown "" options);
     json = builtins.toJSON options;
   }
