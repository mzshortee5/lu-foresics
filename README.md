# lu-foresics
QB CORE | Check items in inventory and provide the information to the player

Works with Ox and Qb Inventory


This is Job Locked for PD Only -- Customizable 


How the menu will pop up for you to choose the item you want to analyze 
<img width="1285" height="797" alt="image" src="https://github.com/user-attachments/assets/78752423-2461-4909-8c2b-df6adbddbadc" />


How the notification will show up for the user
<img width="1672" height="620" alt="image" src="https://github.com/user-attachments/assets/9974151a-9d37-45fb-9e12-9a3543b05622" />


# qb-analyzer-npc

NPC-based **Inventory Analyzer** for QBCore servers with optional OX Inventory support. Players can target a placed NPC to open a categorized inventory menu (Drugs / Ingredients / General) and view informational messages about selected items. Includes a job-locked **command** (`/analyzeinv`) that can play a clipboard emote during the flow.

> **Strictly informational**: the analyzer never consumes or alters items.

---

## ✨ Features

- 🧍 **NPC + qb-target** interaction (`Analyze Inventory`)
- 🧾 **qb-menu** UI with **categories**: Drugs, Ingredients, General
- 🔔 **qb-notify** messages on selection (shows enhancement flags)
- 🧰 **QB Inventory** _or_ **OX Inventory** support (auto/forced)
- 🔒 **Job-locked** access (min-grade per job)
- ⌨️ Optional **command** (`/analyzeinv`) with **clipboard emote**
- 🗄️ **Data source modes**: **Config** or **DB** (or **Auto** fallback)
- 🛡️ No mutations—read-only analyzer

---

## 📦 Dependencies

- `qb-core`
- `qb-target`
- `qb-menu`
- `oxmysql` (only if `Config.Source.Mode` can be `db` or `auto`)
- `ox_inventory` (optional; only if you use OX Inventory)

---

## 📁 Files

```
qb-analyzer-npc/
├─ fxmanifest.lua
├─ config.lua
├─ server.lua
└─ client.lua
```

---

## 🚀 Installation

1. Drag `qb-analyzer-npc/` into your server’s resources.
2. Ensure **order** in `server.cfg`:
   ```cfg
   ensure qb-core
   ensure qb-target
   ensure qb-menu
   ensure oxmysql      # if using DB mode or auto
   # ensure ox_inventory  # if you use OX
   ensure qb-analyzer-npc
   ```
3. (DB mode) Create the minimal tables if they don’t exist (see **Database** below).

---

## ⚙️ Configuration (`config.lua`)

### Inventory backend
```lua
Config.Inventory = {
    System = "auto",      -- "auto" | "qb" | "ox"
    PreferOxWhenBoth = true
}
```

### Data source / categorization
Choose where the analyzer gets item info & categories:
```lua
Config.Source = {
    Mode    = "auto",     -- "db" | "config" | "auto"
    Enabled = true        -- relevant for "db"/"auto"
}
```
- **db**: categorize via DB tables (Ingredients = `harvestable_items.name`, Drugs = `crafting_recipes.name`).
- **config**: use `Config.ItemDescriptions` only (no DB).
- **auto**: try DB; fallback to Config if queries fail/disabled.

DB table/column names:
```lua
Config.DB = {
    IngredientsTable = "harvestable_items",
    DrugsTable       = "crafting_recipes",
    NameColumn       = "name"
}
```

### Defaults for missing descriptions
```lua
Config.Defaults = {
    IngredientDesc = "Ingredient item used in crafting.",
    DrugDesc       = "Controlled substance with potential effects.",
    GeneralDesc    = "No additional information available."
}
```

### Per-item config (used in CONFIG mode, and for DRUG flags in DB mode)
```lua
Config.ItemDescriptions = {
    -- Drugs (flags optional)
    weed = { desc="Cannabis plant.", category="Drugs", speed=false, armor=false, health=true },
    coke = { desc="Cocaine powder.", category="Drugs", speed=true,  armor=false, health=false },

    -- Ingredients
    water = { desc="Bottle of water that quenches thirst.", category="Ingredients" },

    -- General
    bandage = { desc="Stops minor bleeding.", category="General" }
}
```
> In **Ingredients (DB)** mode, flags are forced to **false/false/false**. In **Config** mode, Ingredients default to false/false/false if not set.

### Job lock
```lua
Config.JobLock = {
    Enabled = true,
    Allowed = {
        police    = 0,   -- min grade
        sheriff   = 0,
        ambulance = 0
    }
}
```

### Command
```lua
Config.Command = {
    Enabled     = true,            -- toggle the command
    Name        = "analyzeinv",    -- /analyzeinv
    Suggestion  = true,            -- add chat suggestion
    EmoteOnUse  = true             -- hold clipboard emote during command flow
}
```

### NPCs
```lua
Config.Peds = {
    {
        model = 's_m_y_cop_01',
        coords = vec4(441.77, -981.92, 30.69, 90.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    }
}
```

### UI text
```lua
Config.MenuTitle  = "🔍 Inventory Analyzer"
Config.CloseLabel = "⬅ Close"
Config.Notify = {
    Empty  = "Your inventory is empty.",
    Fetch  = "Contacting analyzer...",
    NoAuth = "You are not authorized to use this."
}
```


## 🕹️ Usage

### Via NPC (qb-target)
- Look at the analyzer NPC and select **“Analyze Inventory”**.
- A **qb-menu** opens showing items under **Drugs / Ingredients / General**.
- Selecting an item shows a **qb-notify**:
  - Description
  - Enhancements: **Speed / Armor / Health** (Yes/No)

### Via command
- If enabled and job-allowed, use: `/<command>` (default `/analyzeinv`).
- Plays a **clipboard emote** during analysis (toggle with `EmoteOnUse`), and stops when:
  - Inventory is empty, **or**
  - You select an item, **or**
  - You close the menu.

---

## 🧩 Customization Tips

- **Hide “General” in DB mode**: filter that category before building `qb-menu`.
- **More categories?** Extend the categorize step and menu builder on client/server.
- **Per-job NPCs**: duplicate entries in `Config.Peds` and adjust `canInteract` job logic if needed.
- **Change the emote**: replace `"WORLD_HUMAN_CLIPBOARD"` with another scenario.

---

## 🛠️ Troubleshooting

- **Menu doesn’t open**: check `qb-menu` and `qb-target` are ensured and no console errors.
- **Empty list**: ensure your inventory backend is correct (`Config.Inventory.System`), and the player has items.
- **DB mode shows only General**: verify tables exist & have `name` rows; check console for query errors.
- **Job lock issues**: confirm `Config.JobLock.Enabled` and job names/grades match your framework.
- **OX Inventory not detected**: set `Config.Inventory.System = "ox"` to force.
- **Emote keeps playing**: ensure the `StopClipboardEmote()` calls are present in close/empty/selection paths.

---

## 🔐 Notes

- Job checks are done on both server (for the command) and client (for NPC/UX).
- The analyzer never removes items—**read-only** by design.

---

## 📄 License & Credits

- Made for QBCore servers. Free to modify for your server.
- Credits: you & contributors. Add your license of choice here.

---

## 🧾 Changelog

**v1.7.0**
- Command toggle (`Config.Command.Enabled`), rename, suggestions, emote toggle.
- Clipboard emote on command flow; stops on close/empty/selection.
- Source modes: `db` / `config` / `auto`.
- DB categorization: Ingredients (harvestable_items), Drugs (crafting_recipes).
- Dual inventory support (QB/OX), job-locked access, categorized menu, notify flags.
