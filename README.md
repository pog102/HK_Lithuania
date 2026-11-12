# Hollow Knight — Lithuanian translation

A complete Lithuanian (LT) translation of Hollow Knight, installed by replacing
four files in the game folder. Everything else in the game is left untouched and
all other languages keep working.

* **Translation:** 36 localisation sheets, 4091 strings (menus, dialogue,
  journal, lore tablets, achievements, credits, item descriptions…).
* **Typography:** the 14 Lithuanian letters `Ą ą Č č Ė ė Ę ę Į į Ų ų Ū ū` are added
  to the game's Perpetua typeface (`Š š Ž ž` were already there). They are
  composed from Perpetua's own letters and Perpetua's own
  `ogonek`/`caron`/`dotaccent`/`macron` marks, so they match the rest of the
  typeface.

---

## 1. Install / uninstall

### Windows (double-click)

1. Unzip `HollowKnight-Lithuanian.zip` anywhere (the Desktop is fine).
2. Double-click **`install.bat`**.
3. It finds Hollow Knight in your Steam libraries, backs the original files up
   as `*.orig` and installs the translation.
4. Start the game and pick **Lietuvių** in *Options → Game Options → Language*.

If the game is in a Steam library the script does not know about, run it from a
command prompt with the folder:

```
install.bat "D:\SteamLibrary\steamapps\common\Hollow Knight"
```

To remove the translation again, double-click **`uninstall.bat`** — it restores
the original files from the backups.

> Steam's *Verify integrity of game files* restores the original game files and
> therefore removes the translation.

### Linux 

```
./install.sh                      # auto-detects the Steam installation
./install.sh "/path/to/Hollow Knight"

./uninstall.sh                    # restores the files from the *.orig backups
```

`install.sh` copies the four patched files into `hollow_knight_Data/` and keeps
the originals next to them as `*.orig` (only the first time).

### Which files are replaced

| File | What changed |
|---|---|
| `hollow_knight_Data/resources.assets` | 36 new `LT_*` text assets holding the encrypted Lithuanian sheets. |
| `hollow_knight_Data/globalgamemanagers` | The resource table (`ResourceManager.m_Container`) gains the 36 `languages/lt_*` entries so Unity's `Resources.Load` finds the sheets. |
| `hollow_knight_Data/sharedassets0.assets` | The two Perpetua font atlases grow from 1024×1024 to 1024×2048 and gain the 14 Lithuanian glyphs. |
| `hollow_knight_Data/Managed/Assembly-CSharp.dll` | `SupportedLanguages` / `TestingLanguages` gain the member `LT = 124` (metadata only — no code is changed). |

`resources.assets.resS` and `sharedassets0.assets.resS` are **not** touched.

---


## 2. How the localisation is stored in the game

* The game loads sheets with `Resources.Load("Languages/<LANG>_<Sheet>")`; those paths are
  listed in the `ResourceManager.m_Container` inside `globalgamemanagers`.
* A sheet is a UTF-8 XML document that is encrypted with **Rijndael/AES-128-ECB**, PKCS#7
  padding, key `UKu52ePUBwetZ9wNX88o54dnfKRu0T1l`, and then base64 encoded — that string is
  the `TextAsset` stores (`TeamCherry.SharedUtils.Encryption`).
* `hk/encryption.py` implements exactly that; `hk/patch_text.py` creates the
  `TextAsset` objects and updates the resource table.
* `LanguageCode` (in `TeamCherry.Localization.dll`) already contains `LT = 124`, but the
  in-game language list is built from `SupportedLanguages` in `Assembly-CSharp.dll`, which is
  why that enum needs the extra member.

---

## Credits

* Translation: produced with the help of an AI, reviewed and corrected by hand.
* Typeface (Perpetua) and the game belong to Team Cherry.
