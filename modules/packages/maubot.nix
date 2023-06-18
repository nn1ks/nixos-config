{ lib
, encryptionSupport ? true
, python3
, runCommand
, fetchpatch
}:

with python3.pkgs; buildPythonApplication rec {
  pname = "maubot";
  version = "0.3.1";
  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ywvrvvq36f1bh4hl9xamj09249px0v4f0v99bgwpr7vpsxrjyhw";
  };

  patches = [
    # add entry point
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/maubot/maubot/pull/146.patch";
      sha256 = "0yn5357z346qzy5v5g124mgiah1xsi9yyfq42zg028c8paiw8s8x";
    })
  ];

  propagatedBuildInputs = [
      # requirements.txt
      mautrix
      aiohttp
      yarl
      sqlalchemy
      asyncpg
      aiosqlite
      CommonMark
      ruamel-yaml
      attrs
      bcrypt
      packaging
      click
      colorama
      questionary
      jinja2
    ]
    # optional-requirements.txt
    ++ lib.optionals encryptionSupport [
      python-olm
      pycryptodome
      unpaddedbase64
    ];

  passthru.tests = {
    simple = runCommand "${pname}-tests" { } ''
      ${maubot}/bin/mbc --help > $out
    '';
  };

  # Setuptools is trying to do python -m maubot test
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [
    "maubot"
  ];

  meta = with lib; {
    description = "A plugin-based Matrix bot system written in Python";
    homepage = "https://github.com/maubot/maubot/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ chayleaf ];
  };
}
