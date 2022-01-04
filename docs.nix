{ pkgs ? import ./test/nixpkgs {}
, module ?  import ./system { config = {}; inherit pkgs; inherit (pkgs) lib; } 
}:
let inherit (pkgs) lib;
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
        description = lib.optionalString (lib.hasAttr "description" v) v.description;
        example = lib.optionalString (lib.hasAttr "example" v) v.example;
        suboptions = getOptions subopts;
      }) a;
    options = getOptions module.options;
    generateMarkdown = parent: opts:
      let h = n: lib.concatMapStrings (_: "#") (lib.lists.range 1 n);
          p = if parent == "" then "" else parent + ".";
          ex = v: if lib.isString v.example
            then v.example
            else if lib.isAttrs v.example
              then if lib.lists.elem v.example._type ["literalExample" "literalExpression" ]
                then "\n```\n" + v.example.text + "\n```"
                else builtins.toJSON v.example
              else builtins.toJSON v.example;
      in
      lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: if !(lib.hasAttr "_type" v) then "" else ''
        ### `${p + k} :: ${v.type.description}`

        ${if v.description != "" then "Description: ${v.description}" else ""}

        ${if v.example != "" && v.example != {} then "Example: ${ex v}" else ""}

        ${generateMarkdown (if v.type.name == "attrsOf" then p + k + ".<name>" else p + k) v.suboptions}
      '') opts);
in { md = (generateMarkdown "" options);
     json = builtins.toJSON options;
   }
