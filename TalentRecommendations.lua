local _, AngusUI = ...

local panelWidth = 360
local sectionHeight = 24
local sectionSpacing = 4
local sectionCount = 5
local panelHeight = (sectionHeight * sectionCount) + (sectionSpacing * (sectionCount - 1))
local panelOffsetX = 10
local panelBottomOffset = 110

local recommendations = {
    DEATHKNIGHT = {
        [250] = {
            title = "Blood Death Knight",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength >> Haste >= Crit >= Mastery = Versatility", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWGzMmxMjhZZmZmmZxYmxMmBAAAAzMzMzMzMDzYMAgZmZGAAAGYgZspxyGILDYDwMMDAAMzADGA" },
                { key = "mythicplus_sanlayn", title = "Mythic+ (SL)", stats = "Strength >> Haste >= Crit >= Mastery = Versatility", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWmZmxMmZmhZZmZmmZxYMmxAAAAAmZmZmZmZYGjBAjZmZGAAAGYgZspxyGILDYDwMmBAAMzADGA" },
                { key = "mythicplus_deathbringer", title = "Mythic+ (DB)", stats = "Strength >> Crit >= Mastery = Versatility > Haste", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwMzyMzMmxMzMMLzMz0MLGjxMGAAAAwMmZmZmZYGjBAjZmZGAAAjZbgBsEsNMBGWAMjZAAYmBwgB" },
                { key = "delves", title = "Delves", stats = "Strength >> Crit = Mastery = Versatility > Haste", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWmZmxMmZmhZZmZmmZxYmxMGAAAAwMzMzMzMDzYMAYMzMzAAAYMbDMglgthJwwCgZMDAAzMAgB" },
            },
        },
        [251] = {
            title = "Frost Death Knight",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength >> Crit >= Mastery >> Haste > Versatility", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMDYmZMzMDY2mZmZmZxMjMjxMDzw4BMzgZmZmZAAAAAAAAAwY2GYALglhJkxCmZMzMwMAGmZAmBM" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Crit >= Mastery >> Haste > Versatility", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMAzMjZmZAz2MzMzMLmZkZMmZmZGYMzwMzMjZAAAAAAAAAwY2GYALglhJkxCmZYmBmBwwMDwMgB" },
                { key = "delves", title = "Delves", stats = "Strength >> Crit >= Mastery >> Haste > Versatility", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMDYmZMzMDY2mZmZmZxMjMjxYYGgZmZmZmZmZAAAAAAAAAwY2GYALglhJkxCmZmZmBGAGmZAmBM" },
            },
        },
        [252] = {
            title = "Unholy Death Knight",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength > Mastery >= Crit > Haste >> Versatility", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAwMjZMDDz2MzMTzmZmZMjBAAAAAAAgZeAmZAwyMmZ2mZGzYGwmZxwQGY2YoxCAmBAmZGzAMzMjZMA" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Mastery >= Crit > Haste >> Versatility", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAYmZMjZMDz2MzMTDzMmZGDAAAAAAAAzMMzAglhZmtZmxMGgFzihhMwsxQjFMgZAYMzMMAzMDzYA" },
                { key = "delves", title = "Delves", stats = "Strength > Mastery >= Crit > Haste >> Versatility", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAYmhZMjZY2mZmZa2MzYmZMAAAAAAAAMzwMDAWGmZ2mZGzYAWMLGGyAzCDNWwAmBgxMzwAMzMMjB" },
            },
        },
    },
    DEMONHUNTER = {
        [577] = {
            title = "Havoc Demon Hunter",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYGMzMzmxMzMmZmMmZAAAAAAAzyDMmtZYmZ2mZGbz28AzwYYsMw2sYGDzmmGzMjhNAAAAAAAAmZwAAAAwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Crit > Mastery >> Haste > Versatility", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYmZmZmZ2mxMzMGzkxMDAAAAAAYWMmtZYmBmx2sNzMjxALDsNbmxwsopxMzYGbAAAADAAAgZGMAAAAM" },
                { key = "delves", title = "Delves", stats = "Agility >> Crit > Mastery >> Haste > Versatility", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYmZmZmZ2mxMzMGzkxMDAAAAAAYWMmtZYmBmx2sNzMjxALDsNbmxwsopxMzYGbAAAADAAAgZGMAAAAM" },
            },
        },
        [1480] = {
            title = "Devourer Demon Hunter",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect > Haste >= Mastery >> Crit >> Versatility", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2MmZmxMzMGzMAAAAAAAegxsNYGAAAAAAAAmxMMmZmZMzMzYmFzYsotNmZmZ2abmZGADDABmZGMmB" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Haste = Mastery >> Crit >> Versatility", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2mxMzMzMzMGmBAAAAAAgxsNYGAAAAAAAAmxMMmZmZmZmZGzsYGjFtsxMzMzWLzMzAYYAIwMGMmB" },
                { key = "delves", title = "Delves", stats = "Intellect > Mastery > Haste >> Crit >> Versatility", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2MmZmxMzMGzMAAAAAAALzYADAAAAAAAAmxMMmZmZmZmZYmtZGjNZDABMAzMzMzyMz0sNz2MzYMzA" },
            },
        },
        [581] = {
            title = "Vengeance Demon Hunter",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility >> Haste = Crit = Versatility >= Mastery", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjZmZkZmZYWMzMjhZMzYGzYmZYGmx2YGjBAAAAAAACYmZsBAAAgBjZmZml2mZmBAzAAAAYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Haste = Crit = Versatility >= Mastery", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjhZkZmBWMjZwMjZGz8AzMzYYmtZGbjZMGzAAAAAAAIgZmxGAAAAGYmZmZWabmZGAMDAAAgB" },
                { key = "delves", title = "Delves", stats = "Agility >> Haste = Crit = Versatility >= Mastery", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjxMjMzMwiZMDmZMzYmHYGzYMzsNzYbMDGzAAAAAAAIgZmxGAAAAGMzMzMzSbzMzAADAAAgB" },
            },
        },
    },
    DRUID = {
        [102] = {
            title = "Balance Druid",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect > Mastery > Crit = Haste > Versatility", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNjxMDMmlZmZmBYYWmZbYmZGbsMzyMjhZBDAGgltxGmmZWGBAAAYzMzMzgNjhxMAmZAgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Mastery > Haste = Crit > Versatility", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNMmZgxsMzMzMLMgZZmlZWMzMWYZmlxMjxGGAMW2mZwY2GBmAAAAswMzMD2MmxYAAYmBGA" },
                { key = "delves", title = "Delves", stats = "Intellect > Mastery > Crit = Haste > Versatility", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNMmZgxsMzMzMLMwMmZbsNjZsNzyMGjBLYAwAssN2w0MzyIAAAAbMzMzgNjZMmBwMDAMA" },
            },
        },
        [103] = {
            title = "Feral Druid",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjZwMzMzMmtlxyMbzYGzMDAAAALBzihxMjaGziZmZGjZYAAAAAAMwAAAAIAY2mZpZbmlNwMDwiZwAAYmBAD" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmZYmZmZMzsZsNz2MzMzDMzAAAAwSwsYMMzomxsYmZmZZMzAAAAAAgBAAAAoZWmtZmZABWAzMALMYAAAMzGG" },
                { key = "delves", title = "Delves", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmZYmZmZMzsZsNz2MzMzDMzAAAAwSwsYMMzomxsYmZmZZMzAAAAAAgBAAAAoZWmtZmZABWAzMALMYAAAMzGG" },
            },
        },
        [104] = {
            title = "Guardian Druid",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility > Haste > Versatility > Crit > Mastery", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmxsMPwYM2MLzMPgZZZgZDGNRzMzyMzMzYMjZAAAAAADLzAAAAQNzysMzMDAgFMzAsYGMYwy2AgZWgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Haste > Versatility > Crit > Mastery", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmZmlZGjxiZh5BmZZZgZzwoJamZWmZmZmlxMAAAAAAMsMDYZbmBjZZAMFAAAYzYmHAYxMYwgltBYmBwA" },
                { key = "delves", title = "Delves", stats = "Agility > Haste > Versatility > Crit > Mastery", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMjxiZZMPgZZZgZzMGNRzMziZmZmlxMAAAAAAMsNDYZbmBjZZAMFAAAYDz8ADYxMYwgltBYmBwA" },
            },
        },
        [105] = {
            title = "Restoration Druid",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect > Haste = Mastery > Versatility >> Crit", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMjxMbz2MmZGzywDMmxmxCzAAAAAAAAAAgtBNbMmmhxMmlZmZmhhZGAAAAAAAAstM2w0MzyAAAEwCjZGMzA0MAYmBAMA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Haste > Mastery > Versatility > Crit", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8AMzsMjNbzAAAAAAAAAAglBNbw0MMjxsYmZmZZGegZAAAAAAAwAAQAAAz2MbNLzsYjxMDMzCoZAAmZAYA" },
                { key = "delves", title = "Delves", stats = "Intellect > Haste > Versatility > Crit > Mastery", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMMmxYGzMjZbmZYYhZx2MAAAAAAAAAAYbQzmhpZMzYMLmZmZWmhxAAAAAAAYMAAEAAwws1sMWsBz8AYGLgmBAYmBgB" },
            },
        },
    },
    EVOKER = {
        [1467] = {
            title = "Devastation Evoker",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Crit >= Haste = Mastery > Versatility", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzMDMDzYmBMYMTzMzMNjx2MmZmZmHYmZGwMmxYmZZmZgBGDWglxox2AyMIYDDMzghB" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Crit >= Haste = Mastery > Versatility", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmZgZ8AzgBGGjZaMzMNjx2MmZmZGzMzAmZmxYmZZmZgBGDWglxox2AyMIYDzgZGMMA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Crit >= Haste = Mastery > Versatility", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwMzMDMDzMMwwYMTjZmpZMzyMmZmZGzMzAmZGDzMLzMDMADWglxox2AyMIYDDMzgZMA" },
            },
        },
        [1468] = {
            title = "Preservation Evoker",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Haste > Crit > Versatility", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAYmZ2WGYGzMPwsYMzMzyAAAMzYGDmxMyMzAAAAMzMTmxMjZbmZAwAjZsxCMwMaoBsAjZGgxA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste >= Mastery = Crit > Versatility", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAMzMz2yADzMmFzYM2mxAAAzYmZGmhZyMmBAAA2mZmJjZmZGjZAAYMjNWgBmRDNMsAzMzAwA" },
                { key = "delves", title = "Delves", stats = "Intellect > Haste > Crit > Versatility > Mastery", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAmZmZ2MwYmZGMzMDbAAAYYMDzYGZmZAAAALzMz0MGzMjZmBAgxM2YDGYGN0gxCMmZAmZA" },
            },
        },
        [1473] = {
            title = "Augmentation Evoker",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Crit > Haste > Mastery > Versatility", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmxMbzMzMWGYmlZMGmZDAAAAAGAAMzMwgxUjZmZAAAAwMmZGzMbjZGYmNjBLwyYYsNAmJiNMzAzMAG" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Crit > Haste > Mastery > Versatility", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmZmZbmZmxyAzsMjxwMAAAAAAAAYmBmBjHoGzMzAAAAgZmZmxMzyYmBmZzYwCsMGGbDgZiYDzMDmZAM" },
                { key = "delves", title = "Delves", stats = "Intellect >> Crit > Haste > Mastery > Versatility", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmZmZbmZmxyAzsMjxwMAAAAAAAAYmBmBjHoGzMzAAAAgZmZmxMzyYmBmZzYwCsMGGbDgZiYDzMDmZAM" },
            },
        },
    },
    HUNTER = {
        [253] = {
            title = "Beast Mastery Hunter",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility > Mastery > Haste > Crit > Versatility", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAAMmxwCsAzwQDbAAYGPw2YmtZGmxMDDzMGzMMzYGzwMzYGzghmBAAAAAMDAAAzMzMAzshwwsA2MA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Mastery > Crit > Versatility > Haste", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAAMmxwCsBzwQDbAAYmx2MzsYGmZmZYGzMGmhZGzMzYbmZYMDLDNDAAAAAYGAAAmHYMzAmZDBMLgND" },
                { key = "delves", title = "Delves", stats = "Agility > Mastery > Crit > Versatility > Haste", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAAMmxwGsAzwQDbAAYGzyMzwMMzMzMmZGjZMDzMzMmhZmhxMDjpZAAAAAAAAAwYMDwMLIYZmFwmB" },
            },
        },
        [254] = {
            title = "Marksmanship Hunter",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGNWGAzgNAAAAAAAAgZMjZYGzMjZwYaGjZmZbbzMzMMzgZmlxYWGMDAAYMzMDAzMttBDw2wA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGNWGAzgNAAAAAAAAgZMzMjtZMzMmhlx0MGjZ222MzMDzMsMzsMGzywMDAAgxYAYmpFGGgNM" },
                { key = "delves", title = "Delves", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGN2GAzgNAAAAAAAAgZMjZYGzMjZGeATzYMmZbZzMzMMzwyMz2YMbDzMAAgZGDAMz0GWmBYDD" },
            },
        },
        [255] = {
            title = "Survival Hunter",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility > Mastery > Crit > Haste > Versatility", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMWgBmxoxyAYmgNjZmxMPwy8AAAAAAAMjZmZYGDjZwYaGAAAAwAAYZbmZWMzMzYmZMAMDbMMGzYjB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Mastery > Crit > Haste > Versatility", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMgxMG2ILwMM0gFzMzMzwyAAAAAAgZMzMDzYYMDGTzAAAAAGAALLzMziZmZmZGzMgZ2AgxYmZhB" },
                { key = "delves", title = "Delves", stats = "Agility > Mastery > Crit > Haste > Versatility", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMgxMG2ILwMM0gFzMzMzwyAAAAAAgZMzMDzYYMDGTzAAAAAGAALLzMziZmZmZGzMgZ2AgxYmZhB" },
            },
        },
    },
    MAGE = {
        [62] = {
            title = "Arcane Mage",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery >> Haste > Crit = Versatility", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMzQzMzAAAwAAgAmZmZZZmZYBAgtxMzMmtFLzMzYmxYMzMGLMzMjZAAGAAAzsAAmBADD" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery >> Haste > Crit = Versatility", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzswMzQzMGAAAGAAEwMzMLLzMxCAAbzYmZMbmlZmZMzYMmZmZswMzMGAADAAgZWAADAMM" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery >> Haste > Crit = Versatility", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzswMzQzMGAAAGAAEwMzMLLzMxCAAbzYmZMbmlZmZMzYMmZmZswMzMGAADAAgZWAADAMM" },
            },
        },
        [63] = {
            title = "Fire Mage",
            tabs = {
                { key = "sunfury_raid", title = "Sunfury Raid", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDZmZGAAAGAwMz0sssMDAwmZmx2wYmBAAAAAsYmZmZAAwYGzYmZMz2AwMDZMGDmhB" },
                { key = "frostfire_raid", title = "FF Raid", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDZmZGAAAmZZGzMLzCEAAwiZmx2YmZGAAAAAgFzMzMDAAGzYmZmZmZ2AmZADzYMYwA" },
                { key = "sunfury_mythicplus", title = "Sunfury+", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmxAAAwAAmZmmlltZAA2MzM2GzMzYDAAAAAWMzMzMAAYMDjZmZmZbAYmhwYMYGG" },
                { key = "frostfire_mythicplus", title = "FF+", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmxAAAwMLzYmZZWgAAAWMzM2GzMzYBAAAAAWMzMzMAAYMjZmZmZmZDYmBMYMGMYA" },
                { key = "frostfire_delves", title = "FF Delves", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmxAAAwMLzYmZZWgAAAWMzM2GzMzYBAAAAA2MzMzMAAYMjZmZmZmZDYmBMYMGMYA" },
            },
        },
        [64] = {
            title = "Frost Mage",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery >= Crit > Haste >= Versatility", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmxMjZMziZmZmZMDAAAMzMzyyMTbAAAAAAgNA22GzMzgZZeAjZYBAAgZWAmJjBMDGA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery >= Crit > Haste >= Versatility", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFmZmYGmZmZmZWMzMMjZAAAgZmZWWmZaDAAWAAAAWAYbbMzMDmthxMjNAAAmZDYmMGwMYA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery >= Crit > Haste >= Versatility", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMzEzMzMzMzMziZmhZMDAAAMzMzyyMTbAAAAAAgFA22GzMzgZbYMzYDAAgZ2AmJjBMDGA" },
            },
        },
    },
    MONK = {
        [268] = {
            title = "Brewmaster Monk",
            tabs = {
                { key = "raid_def", title = "Raid Def", stats = "Agility >> Crit = Versatility = Mastery > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAgZbzYGPwYWM2mxMDAAAAAAALLYEmBmhxmZMmZmZMzywMmZZYZzy2sMMLAAwysMtMbzsMAAQAmhNwMDYaMAAgB" },
                { key = "mythicplus_std", title = "M+ Std", stats = "Agility >> Crit = Mastery > Versatility > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAwMLbGDzwyM2MmZAAAAAAAYZBmYmBmhBzgZmZGzsNMjZWGW2ssNbzYWAAgNEAAgZbWamZmNG2AYmhpxAGAwA" },
                { key = "delves", title = "Delves", stats = "Agility >> Crit = Versatility = Mastery > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAgZZzYGzwyM2MmZMAAAAAAALLgYmBmhBzgZmZGzsNMjZWGW2ssNbzYWAAglZZaZ2mZZAAgAYYDMzAmGDYAAD" },
            },
        },
        [269] = {
            title = "Windwalker Monk",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility > Haste > Crit >= Mastery >> Versatility", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDjwMMMgZMMzMzwsMMDzyMBAsZmtxwYmZAAsBAzys0MzMLADDMzAwYZMEDYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Haste > Crit >= Mastery >> Versatility", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDzEmhhBMjhZmZGmthZYWmJAgNzsNGGzMDAgNAYWmlmZmZBYYgZGAYZMEDYA" },
                { key = "delves", title = "Delves", stats = "Agility > Haste > Crit >= Mastery >> Versatility", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDzEmhhBMjhZmZGmthZYWmJAgNzsNGGzMDAgNAYWmlmZmZBYYgZGAYZMEDYA" },
            },
        },
        [270] = {
            title = "Mistweaver Monk",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Haste > Crit > Versatility >> Mastery", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghx2MwmFzYmZbGbYmZYmlttZGLMjmxMgBDGzyMzMDz2gBLmAAAAAIALWmZZ2mZAAgBMAzAGDjFZMDA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste > Crit > Versatility > Mastery", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMWmZZYxmxMjNstsNjZYmttlZGLMjmxMgBDGzyMzMDzGmhZZmAAAAAIAL2mZZ2mZAAAgBYGwYgFZMDA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Haste > Crit > Versatility > Mastery", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMWmZZML2mxMjNDYMzmZ222mZswQzYGLYwAGzMzMMbDzwsMTAAAAAEgFbzsNbzMAAAwAMDYMMDZMDA" },
            },
        },
    },
    PALADIN = {
        [65] = {
            title = "Holy Paladin",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMAAglxMzYGzMzGjxYWGbzMLmpJGzYmZYY2yAwAG2AbsMjZWmtZmZrBAAAYBA2MMmxMAAgZGmxY0A" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMDAwglxMzMzYmZWgxwyYbmZxMNxwYmZYY2yAwAwGYjlZmZWmtZmZrBAAAYhNMDbGYGzAAAmZYGjRD" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMDAwglxMzMzYmZWgxwyYbmZxoJGGmZYY2yAwAwGYjlZmBABAMzsstYbmhN2YgNDMjZYAYmBgZMGNA" },
            },
        },
        [66] = {
            title = "Protection Paladin",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength > Haste = Versatility > Crit > Mastery", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsZm5BYWGLzMjZGbLjxYmFbzYAAGAAAAAAkmZWMjZmxYmt2AwAGwgNAAwMTbzMLzAAsBmxAYMDjBAYZGgZGkB" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Haste = Versatility > Crit > Mastery", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsZMYWGLzMjZmZZZMzwsMLzYAAAAAAAAgmmZWMjZGGGBADYAD2GAAABYmZZbplZGLmhZMAGzwYAwMDAzMDyA" },
                { key = "delves", title = "Delves", stats = "Strength > Haste = Versatility > Crit > Mastery", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsNjBzyYZMjZmZZZMzwsMLzYAAGAAAAAA00MziZMzwws1GAGYAzgNAAwMTbzMLzAAsZGMAYMDjBAYZGgZGkB" },
            },
        },
        [70] = {
            title = "Retribution Paladin",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength > Mastery > Haste = Crit > Versatility", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQz22MzsMMzAAAAAAwoMmhZGbDz2wMbzYMmZYGbsNMAAkZm2mZ2mBAsBYAwYGmBzYMbYZGMMmxgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Mastery > Haste = Crit > Versatility", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAMa22mZmlxMzMAAAAAAmpMMMzYbY2GmZbGjxMDzYjNMAAkZm2mZ2mBAsBYAwYGGYGjZDLzghxMGM" },
                { key = "delves", title = "Delves", stats = "Strength > Mastery > Haste = Crit > Versatility", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQzyyMzsMzMzMDAAAAAwMlxMYGbzY2GmZbGMegZwYjtBAAkZm2mZ2mBAsBYAAzwMYYmZBLzgxMmxgB" },
            },
        },
    },
    PRIEST = {
        [256] = {
            title = "Discipline Priest",
            tabs = {
                { key = "oracle_raid", title = "Oracle Raid", stats = "Intellect > Haste > Crit > Mastery > Versatility", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsYY2YMDzMjZbsNzMzMMDAAAAAAAAAgZYZGMzMDmxMgpZiBYmFMEGzyAMGsAAAjZmZMMzAMzMTzwA" },
                { key = "voidweaver_mythicplus", title = "VW Mythic+", stats = "Intellect > Haste >> Crit > Mastery > Versatility", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsYMzGjxYmZMbsNzMzMzAAAAAAAAAAgxYZGMzMjNjZGsZamAmZAQAMLzyCYsZAAYMzMjBzgZGMaGG" },
                { key = "delves", title = "Delves", stats = "Intellect >> Haste > Crit > Mastery > Versatility", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsYMzGjxYmZMbsNzMzMzAAAAAAAAAAgxYZGMzMjNjZGsZamGwMDACgZZWWAjNDAAjZmZMYGMzAaGG" },
            },
        },
        [257] = {
            title = "Holy Priest",
            tabs = {
                { key = "archon_raid", title = "Archon Raid", stats = "Intellect >> Crit > Versatility = Mastery > Haste", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAgZBGzygxMzMjZmZsMzYGAAAADzyMMzMzgZMDgZqBAmZxMZWMAwYwmxMLAaGmxYYmZbZAmBG" },
                { key = "archon_mythicplus", title = "Archon+", stats = "Intellect >> Versatility > Crit > Haste > Mastery", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAgZzwYWGMmZmZMzMjlZmZAAAAYMWmBzMzYzYmxAmpAAzsZmMbGAYMYzYsAoZMzYMMzstMADYA" },
                { key = "oracle_raid", title = "Oracle Raid", stats = "Intellect >> Crit > Versatility = Mastery > Haste", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAGjZmlZmZMzYYmxYZmxMAAAAGmlZGzMzMMzYGAzUDgZWwQYMbDwYgFGzCgMMPgxwMDwMzMwA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Versatility > Crit > Haste > Mastery", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAbGGzyYGzMjxMDjlZmZGAAAADzyMjZmZGbGzMmtNMTBAmZxMZ2MAwYwmxYBQDzwYwMLLDwAG" },
            },
        },
        [258] = {
            title = "Shadow Priest",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect > Haste > Mastery > Crit > Versatility", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAgxYxMGLzMMz2MDzw2MzYmZGbIzYxMNAzAMzmZY2MAkxYBAzAZMzMjZbMz2yAMTMA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Haste > Mastery > Crit > Versatility", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAghZxMGLzMMzyMDzw2MzYmZGbIzYxMNAzAMziZY2MAkxYBAzYIjZmZMbjZ2WGgZiB" },
                { key = "delves", title = "Delves", stats = "Intellect > Haste > Mastery > Crit > Versatility", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAghZxMGLzMMzyMDzw2MzYmZGbIzYxMNAzAMziZY2MAkxYBAzYIjZmZMbjZ2WGgZiB" },
            },
        },
    },
    ROGUE = {
        [259] = {
            title = "Assassination Rogue",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYMjZZGMAAAAAwsMYbGAAAAAQbbzMzMzMjxMzMz2MLzMDMjZmZMzMzYAMwCMjRjZBklBsZsBYmZwA" },
                { key = "raid_st", title = "Raid ST", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZMbzgBAAAAAmlBbzAAAAAAabbmZmZmZMmZmZ2mZZmZGMmZmZMzYYAMwCMjRjZBklBsZAwMzgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZmZxgBAAAAAmlBbzAAAAAAabbmZmZmZMmZmZ2mZZmBPwMzMzYYmxYAMwCMjRjZDklBsZsBYmhxA" },
                { key = "delves", title = "Delves", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZmZxgBAAAAAmlBbzAAAAAAabbmZmZmZMmZmZ2mZZmBPwMzMzYYmxYA2MLDMglgthJwwixmZGAGD" },
            },
        },
        [260] = {
            title = "Outlaw Rogue",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility >> Haste = Crit > Versatility > Mastery", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGjZMzsNzMzMjHwswDMzMLTLD2mBAAAAAMbbzMzwMzMzYmZ2GAAAAGADsBzY0Y2AsNhFGAMzMwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Haste = Crit > Versatility > Mastery", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGzMzMzsNzMzYmHYmFGmx0ygtZAAAAAAz22MzMMzMzMmZmtBAAAgBwAbwMGNmNAbTYhBAzMDM" },
                { key = "delves", title = "Delves", stats = "Agility >> Haste = Crit > Versatility > Mastery", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGzMzMzsNzMzYmHYmFGmx0ygtZAAAAAAz22MzMMzMzMmZmtBAAAgBwAbwMGNmNAbTYhBAzMDM" },
            },
        },
        [261] = {
            title = "Subtlety Rogue",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility > Mastery > 18% Haste >= Crit > Versatility", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMjZwDMzMzYMbjZGbbzMzMzMjBjZ2GAAAAGMGwY2MMwAziWoFbYGwMDmxA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Mastery >> 18% Haste >= Crit > Versatility", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMjZMMzMzYMbzYGbbzMzMzMjBjZ2GAAAAGMGwY2MMwAziWoFbYGwMDmxA" },
                { key = "delves", title = "Delves", stats = "Agility > Mastery > 18% Haste >= Crit > Versatility", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMjZMMzMzYMbzYGbbzMzMzMjBjZ2GAAAAGMGwY2MMwAziWoFbYGwMDmxA" },
            },
        },
    },
    SHAMAN = {
        [262] = {
            title = "Elemental Shaman",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Haste = Crit > Versatility", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMbLzMmZmZZbbgxMDAAAAAsYGDbwCMjGasBAzyMzMGbLmwMzyYZmZmxwysMjFzMjZWAAGAzMwwwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery > Haste = Crit > Versatility", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMbLzMzYML2mhZMzAAAAAALmxwGsAzohGbAwsMzMjx2ipNmZMWmZmZMsMLGLmZGzsAAMDwMDMMMA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery > Haste = Crit > Versatility", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMLLzMmZmZbZZMmxMDAAAAYzMbwAGwsxEysAAzyMzMGbLmwMjxyMzMzMjFLGLYMzsAAMAwMjhhB" },
            },
        },
        [263] = {
            title = "Enhancement Shaman",
            tabs = {
                { key = "raid", title = "Raid", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZmZGAAAAAAAAAYB2gZsox2AYmgNAmlZMzMWWmBmZ2YZmZmhhxMAAGgxMTMzAAjB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZGzAAAAAAAAAALwGMjFN2GAzEsBwsMjZMWWMwMz2YZmZmZwyYGAAgxYGxMDwgxA" },
                { key = "delves", title = "Delves", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZmZGAAAAAAAAAYB2gZsox2AYmgNAmlZMjxyyMwMjxiZmZGjFmBAAYMmZiZGAYMA" },
            },
        },
        [264] = {
            title = "Restoration Shaman",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect > Crit > Versatility = Mastery > Haste", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzMLLbDzMGzMmZGzsYmFYATwswEYsYGmBLjxMNbLzMMjZhFzMzYGmlBAAAmZGAMzADG" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Crit > Versatility = Mastery = Haste", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAjZmZbZbYmZmZmZGzYmFzsADYCmFmAjFGzgZZmxoZbZmhZMLsYMzYGLzyAAgBYmZAwMDMYA" },
                { key = "delves", title = "Delves", stats = "Intellect > Crit > Versatility = Mastery = Haste", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAjZmxy2MMzMzMzMmxYxMLwAmgZhJwYBzMY2mZmRz2yMDmZwyMmZMjlZBAAGgZmBAzMMGM" },
            },
        },
    },
    WARLOCK = {
        [265] = {
            title = "Affliction Warlock",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Crit > Haste > Versatility", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZhhZmZmlBAAYmZxyMzsMzAAjllBGwEMDbBG2GAAAmBAAwMDzMjBGmZmZGzgZmZGAwMwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery > Crit > Haste > Versatility", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMjZGNbmxmZGzyAAAmZmlZzMzyYAgx22ADYCmhtADbDAAAGAAAzMjZMzsNzYGMzMzYYmZmBAMDMA" },
                { key = "open_world", title = "Open World", stats = "Intellect >> Mastery > Crit > Haste > Versatility", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMjZGNbmxmZGzyAAAmZmlZzMzyYAgx22ADYCmhtADbDAAAGAAAzMjZMzsNzYGMzMzYYmZmBAMDMA" },
            },
        },
        [266] = {
            title = "Demonology Warlock",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Haste = Crit > Mastery > Versatility", talentCode = "CoQAy0jxIDofkwJmoH7WhvESoZmZMzoZjhZmxsMAAAAAAAjllZMzMsYYYmtZpNaGbGjZ2mlZmZYAgZYmZmZGMzMzMmZAAAGzMzMDzYZGDYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste = Crit > Mastery > Versatility", talentCode = "CoQAy0jxIDofkwJmoH7WhvESoZmhZGNbmx2MzYWGAAAAAAgxyyMmZGWMMMz2s0GNjNjZGLjZmxMDAMzMzYmZGMzMzMMzGAAYMzMjxgtZGgB" },
                { key = "delves", title = "Delves", stats = "Intellect >> Haste = Crit > Mastery > Versatility", talentCode = "CoQAAAAAAAAAAAAAAAAAAAAAAYmhZGNbmx2MzYWGAAAAAAgxyyADYAzwSIjNjZGLz2MzwMAwMzMzMDwMzMzwMbAAgxMzMGD2mBwA" },
            },
        },
        [267] = {
            title = "Destruction Warlock",
            tabs = {
                { key = "raid", title = "Raid", stats = "Intellect >> Haste > Mastery >= Crit > Versatility", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZjhZmZmlZjxMLGjFzAAgZmxMzsAGzYYhMw2wGNWYAAgxAjNAMzAYmxYAAAYmZmBAwMDD" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste > Mastery > Crit > Versatility", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMjZGNLmxiZGzysNzYsYmZZZmBAAzgZmZxCMwsY0YGAzWsxAAAjZYAAwMDGzMmZDAAwMzMDAAzwA" },
                { key = "open_world", title = "Open World", stats = "Intellect >> Haste > Mastery > Crit > Versatility", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZjhZmxsMLjxMLGz2CDAAmZGzMzCYMjhFyAbDb0YhBAAGDM2AwMDwMzYMbAAAmZmBAgZGG" },
            },
        },
    },
    WARRIOR = {
        [71] = {
            title = "Arms Warrior",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength >> Crit > Haste > Mastery > Versatility", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAAzMzsMzMzMDAAAghphxYmxyMzMzgxMDAAAAgZWmZAZMWWGYBMgZYCZGsBMjNz2YwMGgZGAmxwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Crit > Haste > Mastery > Versatility", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMzYGAAAghphxwMbLzMzMjZGzMAAAAAGbmB2iBsZGDLwAzoNaMYBYGMGMbmtBzMAgZmhB" },
                { key = "delves", title = "Delves", stats = "Strength >> Crit > Haste > Mastery > Versatility", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMzYGAAAghphxwMbLzMzMjZGzMAAAAAGbmB2iBsZGDLwAzoNaMYBYGMGMbmtBzMAgZmhB" },
            },
        },
        [72] = {
            title = "Fury Warrior",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength >> Mastery > Haste > Crit > Versatility", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjxMsMzMzMDjZmZGzMzsMzMGzMbDzMAAQMWWGYBMBzwEYG2AmZ2Y2GAAMzYYMzMMYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Mastery > Haste > Crit > Versatility", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjZMz2yMzMjZmxMjZMjZWmZGjZmlxMzAAAhB2glFjGzAysgZsAYGMGAMzAYYmZGMYA" },
                { key = "delves", title = "Delves", stats = "Strength >> Mastery > Haste > Crit > Versatility", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjZMz2yMzMjZmxMjZMjZWmZGjZmlxMzAAAhB2glFjGzAysgZsAYGMGAMzAYYmZGMYA" },
            },
        },
        [73] = {
            title = "Protection Warrior",
            tabs = {
                { key = "raid", title = "Raid", stats = "Strength > Haste > Crit >= Versatility > Mastery", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAA0yAAAzMzYmZGzMzmxsMjxYmGmZYZMzMDzYmBAAAALDAzYAGYDWWMaMDgZLmZDmxMDmtBAzMAAMAD" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Haste > Crit >= Versatility > Mastery", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAAkBAAGzMzMzMmxsZmZZGjxMNmxwyYmZYmxMDAAAAWGAmxAMwGssY0YGAzWMzGMzMzgZZAwMDAADwA" },
                { key = "delves", title = "Delves", stats = "Strength > Haste > Crit >= Versatility > Mastery", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAAkBAAGzYmZmZmxsZmZZYMmpxMGWGzMzwMmZAAAAwyAwMGAYzMG2IDMDL0YmFGzMzMY2GAgZGAwAMA" },
            },
        },
    },
}

local function GetClassTalentsFrame()
    local playerSpellsFrame = _G["PlayerSpellsFrame"]
    return playerSpellsFrame and playerSpellsFrame.TalentsFrame or nil
end

local function GetCurrentRecommendation()
    local _, classFile = UnitClass("player")
    local classRecommendations = recommendations[classFile]
    if not classRecommendations then
        return nil
    end

    local classTalentsFrame = GetClassTalentsFrame()
    local specID
    if classTalentsFrame and classTalentsFrame.GetSpecID then
        specID = classTalentsFrame:GetSpecID()
    end

    if not specID then
        local specialization = GetSpecialization and GetSpecialization()
        if specialization then
            specID = GetSpecializationInfo(specialization)
        end
    end

    if not specID then
        return nil
    end

    return classRecommendations[specID]
end

local function FormatStatsText(statsText)
    if not statsText then
        return ""
    end

    statsText = gsub(statsText, "%s+>>%s+", " |cffff7a00>>|r ")
    statsText = gsub(statsText, "%s+>=%s+", " |cff58c4dd>=|r ")
    statsText = gsub(statsText, "%s+=%s+", " |cff7fb8ff=|r ")
    return gsub(statsText, "%s+>%s+", " |cffffe066>|r ")
end

local function ShowTalentString(section, tabData)
    if not tabData or not tabData.talentCode then
        return
    end

    local dialog = section.talentDialog
    dialog.talentCode = tabData.talentCode
    dialog.title:SetText(tabData.title .. " Talents")
    dialog.talentCodeBox:SetText(tabData.talentCode)
    dialog:Show()
    dialog.talentCodeBox:SetFocus()
    dialog.talentCodeBox:HighlightText()
end

local function CreateTalentDialog(parent)
    local dialog = CreateFrame("Frame", "AngusUITalentCodeDialog", parent, "BasicFrameTemplateWithInset")
    dialog:SetSize(460, 120)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetToplevel(true)
    dialog:SetClampedToScreen(true)
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:SetPoint("CENTER", parent, "CENTER", 0, 0)
    dialog:Hide()

    dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dialog.title:SetPoint("TOP", dialog, "TOP", 0, -10)
    dialog.title:SetText("Talents")

    dialog.talentCodeBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    dialog.talentCodeBox:SetAutoFocus(false)
    dialog.talentCodeBox:SetSize(390, 20)
    dialog.talentCodeBox:SetPoint("TOP", dialog, "TOP", 0, -42)
    dialog.talentCodeBox:SetFontObject("GameFontHighlightSmall")
    dialog.talentCodeBox:SetTextInsets(4, 4, 0, 0)
    dialog.talentCodeBox:SetMaxLetters(255)
    dialog.talentCodeBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:GetParent():Hide()
    end)
    dialog.talentCodeBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput and dialog.talentCode then
            self:SetText(dialog.talentCode)
            self:HighlightText()
        end
    end)

    dialog.hint = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dialog.hint:SetPoint("TOP", dialog.talentCodeBox, "BOTTOM", 0, -10)
    dialog.hint:SetText("Press Ctrl-C to copy, then Escape to close")
    dialog.hint:SetTextColor(0.8, 0.8, 0.8)

    dialog:SetScript("OnShow", function(self)
        self.talentCodeBox:SetFocus()
        self.talentCodeBox:HighlightText()
    end)

    return dialog
end

local function CreateSection(parent, index)
    local section = CreateFrame("Frame", nil, parent)
    section:SetSize(panelWidth, sectionHeight)
    section:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, ((index - 1) * (sectionHeight + sectionSpacing)))

    section.copyButton = CreateFrame("Button", nil, section, "UIPanelButtonTemplate")
    section.copyButton:SetSize(112, 20)
    section.copyButton:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)

    section.stats = section:CreateFontString(nil, "OVERLAY")
    section.stats:SetFontObject("GameFontNormalSmall")
    section.stats:SetPoint("LEFT", section.copyButton, "RIGHT", 10, 0)
    section.stats:SetWidth(238)
    section.stats:SetJustifyH("LEFT")
    section.stats:SetJustifyV("MIDDLE")
    section.stats:SetTextColor(1, 1, 1)

    return section
end

local function CreatePanel()
    local classTalentsFrame = GetClassTalentsFrame()
    if not classTalentsFrame then
        return nil
    end

    local panel = CreateFrame("Frame", "AngusUITalentRecommendationsFrame", classTalentsFrame)
    panel:SetSize(panelWidth, panelHeight)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(classTalentsFrame:GetFrameLevel() + 200)
    panel:EnableMouse(true)
    panel.talentDialog = CreateTalentDialog(UIParent)

    panel.sections = {}
    for index = 1, sectionCount do
        panel.sections[index] = CreateSection(panel, index)
    end

    for _, section in ipairs(panel.sections) do
        section.talentDialog = panel.talentDialog
    end

    return panel
end

function AngusUI:TalentRecommendationsRefresh()
    local classTalentsFrame = GetClassTalentsFrame()
    local panel = self.talentRecommendationsPanel
    if not panel or not classTalentsFrame then
        return
    end

    local specRecommendation = GetCurrentRecommendation()
    if not specRecommendation or (classTalentsFrame.IsInspecting and classTalentsFrame:IsInspecting()) or not classTalentsFrame:IsShown() then
        panel:Hide()
        return
    end

    panel.specRecommendation = specRecommendation
    panel:ClearAllPoints()
    panel:SetPoint("BOTTOM", classTalentsFrame, "BOTTOM", panelOffsetX, panelBottomOffset)

    for index, section in ipairs(panel.sections) do
        local tabData = specRecommendation.tabs[index]
        if tabData then
            section.talentCode = tabData.talentCode
            section.copyButton:SetText(tabData.title)
            section.stats:SetText(FormatStatsText(tabData.stats))
            section.copyButton:Show()
            section.copyButton:SetScript("OnClick", function()
                ShowTalentString(section, tabData)
            end)
            section:Show()
        else
            section:Hide()
        end
    end

    panel:Show()
end

function AngusUI:TalentRecommendations()
    local playerSpellsFrame = _G["PlayerSpellsFrame"]
    local classTalentsFrame = GetClassTalentsFrame()
    if not classTalentsFrame then
        return
    end

    if not self.talentRecommendationsPanel then
        self.talentRecommendationsPanel = CreatePanel()
        if not self.talentRecommendationsPanel then
            return
        end
    end

    if self.talentRecommendationsHooked then
        self:TalentRecommendationsRefresh()
        return
    end

    self.talentRecommendationsHooked = true

    classTalentsFrame:HookScript("OnShow", function()
        AngusUI:TalentRecommendationsRefresh()
    end)

    classTalentsFrame:HookScript("OnHide", function()
        if AngusUI.talentRecommendationsPanel then
            AngusUI.talentRecommendationsPanel:Hide()
            if AngusUI.talentRecommendationsPanel.talentDialog then
                AngusUI.talentRecommendationsPanel.talentDialog:Hide()
            end
        end
    end)

    if playerSpellsFrame then
        playerSpellsFrame:HookScript("OnShow", function()
            AngusUI:TalentRecommendationsRefresh()
        end)
    end

    hooksecurefunc(classTalentsFrame, "UpdateSpecBackground", function()
        AngusUI:TalentRecommendationsRefresh()
    end)

    self:TalentRecommendationsRefresh()
end
