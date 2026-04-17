local _, AngusUI = ...

local panelWidth = 360
local sectionHeight = 24
local sectionSpacing = 4
local panelOffsetX = 10
local panelBottomOffset = 110

local function GetPanelHeight(sectionCount)
    if sectionCount <= 0 then
        return 0
    end

    return (sectionHeight * sectionCount) + (sectionSpacing * (sectionCount - 1))
end

local recommendations = {
    DEATHKNIGHT = {
        [250] = {
            title = "Blood Death Knight",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/death-knight/blood/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength >> Haste >= Crit >= Mastery = Versatility", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWGzMmxMjhZZmZmmZxYmxMmBAAAAzMzMzMzMDzYMAgZmZGAAAGYgZspxyGILDYDwMMDAAMzADGA" },
                { key = "mythicplus_sanlayn", title = "Mythic+ (SL)", stats = "Strength >> Haste >= Crit >= Mastery = Versatility", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWmZmxMmZmhZZmZmmZxYMmxAAAAAmZmZmZmZYGjBAjZmZGAAAGYgZspxyGILDYDwMmBAAMzADGA" },
                { key = "mythicplus_deathbringer", title = "Mythic+ (DB)", stats = "Strength >> Crit >= Mastery = Versatility > Haste", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwMzyMzMmxMzMMLzMz0MLGjxMGAAAAwMmZmZmZYGjBAjZmZGAAAjZbgBsEsNMBGWAMjZAAYmBwgB" },
                { key = "delves", title = "Delves", stats = "Strength >> Crit = Mastery = Versatility > Haste", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWmZmxMmZmhZZmZmmZxYmxMGAAAAwMzMzMzMDzYMAYMzMzAAAYMbDMglgthJwwCgZMDAAzMAgB" },

                -- Update from: https://www.archon.gg/wow/builds/blood/death-knight/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Crit > Haste > Mastery > Vers", talentCode = "CoPAAAAAAAAAAAAAAAAAAAAAAwMzyMzwMmZmhZZmZmmZxMzMzMAAAAAmxMzMzMDzYMAYMzMzAAAYMbDMgFw2wEYYBwMmBAgZGAwA" },
            },
        },
        [251] = {
            title = "Frost Death Knight",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/death-knight/frost/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength >> Crit >= Mastery >> Haste > Versatility", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMDwMjZMDY2mZmZmZZmZkZMmZYGGPgZGMzMzMDAAAAAAAAAGz2ADYBsMMhMWwMjZmBmBwwMDwMDM" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Crit >= Mastery >> Haste > Versatility", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMAzMjZmZAz2MzMzMLmZkZMmZmZGYMzwMzMjZAAAAAAAAAwY2GYALglhJkxCmZYmBmBwwMDwMgB" },
                { key = "delves", title = "Delves", stats = "Strength >> Crit >= Mastery >> Haste > Versatility", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMDYmZMzMDY2mZmZmZxMjMjxYYGgZmZmZmZmZAAAAAAAAAwY2GYALglhJkxCmZmZmBGAGmZAmBM" },

                -- Update from: https://www.archon.gg/wow/builds/frost/death-knight/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Crit > Mastery > Haste > Vers", talentCode = "CsPAAAAAAAAAAAAAAAAAAAAAAMAzMjZMGDz2MzMzMbmZkZMmZmZGYMzwMzMjZAAAAAAAAAwY2GYALglhJwYBzMMzAzAYYmBYGwA" },
            },
        },
        [252] = {
            title = "Unholy Death Knight",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/death-knight/unholy/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength >> Mastery >= Crit >> Haste >> Versatility", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAwMjZMDDz2MzMTzmZmZMjBAAAAAAAgZeAmZAwyMmZ2mZGzYGwmZxwQGY2YoxCAmBAmZGzAMzMjZMA" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Mastery >= Crit >> Haste >> Versatility", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAYmZMjZMDz2MzMTDzMmZGDAAAAAAAAz8AMzAglZMzsNzMGGgFzmhhMwsxQjFMgZAYMzMmBYmZYGD" },
                { key = "delves", title = "Delves", stats = "Strength >> Mastery >= Crit >> Haste >> Versatility", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAYmhZMjZY2mZmZa2MzYmZMAAAAAAAAMzwMDAWGmZ2mZGzYAWMLGGyAzCDNWwAmBgxMzwAMzMMjB" },

                -- Update from: https://www.archon.gg/wow/builds/unholy/death-knight/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Mastery > Crit > Haste > Vers", talentCode = "CwPAAAAAAAAAAAAAAAAAAAAAAAYmZMjZGDz2MzMTDzMmZGDAAAAAAAAzMMzAglhZmtZmxMGgFzihBGY2YoxCGwMAMmZGGgZmhZMA" },
            },
        },
    },
    DEMONHUNTER = {
        [577] = {
            title = "Havoc Demon Hunter",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/demon-hunter/havoc/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility >> Crit > Mastery >> Haste > Versatility", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYGMzMzmxMzMmZmMmZAAAAAAAzyDMmtZYmZ2mZGbz28AzwYYsMw2sYGDzmmGzMjhNAAAAAAAAmZwAAAAwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Crit > Mastery >> Haste > Versatility", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYmZmZmZ2mxMzMGzkxMDAAAAAAYWMmtZYmBmx2sNzMjxALDsNbmxwsopxMzYGbAAAADAAAgZGMAAAAM" },
                { key = "delves", title = "Delves", stats = "Agility >> Crit > Mastery >> Haste > Versatility", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYmZmZmZ2mxMzMGzkxMDAAAAAAYWMmtZYmBmx2sNzMjxALDsNbmxwsopxMzYGbAAAADAAAgZGMAAAAM" },

                -- Update from: https://www.archon.gg/wow/builds/havoc/demon-hunter/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Crit > Mastery > Haste > Vers", talentCode = "CEkAAAAAAAAAAAAAAAAAAAAAAYmZmZmZ2mxMzMGzkxMDAAAAAAYWMmtZYmBmx2sNzMjxALDsNbmxwsw0YmZMjNAAAgBAAAwMDGAAAAG" },
            },
        },
        [1480] = {
            title = "Devourer Demon Hunter",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/demon-hunter/devourer/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect > Haste >= Mastery >> Crit >> Versatility", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2MmZmxMzMGzMAAAAAAAegxsNYGAAAAAAAAmxMMmZmZMzMzYmFzYsotNmZmZ2abmZGADDABmZGMmB" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Haste = Mastery >> Crit >> Versatility", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2mxMzMzMzMGmBAAAAAAgxsNYGAAAAAAAAmxMMmZmZmZmZGzsYGjFtsxMzMzWLzMzAYYAIwMGMmB" },
                { key = "delves", title = "Delves", stats = "Intellect > Mastery > Haste >> Crit >> Versatility", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2MmZmxMzMGzMAAAAAAALzYADAAAAAAAAmxMMmZmZmZmZYmtZGjNZDABMAzMzMzyMz0sNz2MzYMzA" },

                -- Update from: https://www.archon.gg/wow/builds/devourer/demon-hunter/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Mastery > Haste > Crit > Vers", talentCode = "CgcBAAAAAAAAAAAAAAAAAAAAAAA2mxMzMzMzMGmBAAAAAAgxsNYGAAAAAAAAmxMMmZmZmZmZGzsYGjFtsxMzMzWLzMzAYYAAYGDGzA" },
            },
        },
        [581] = {
            title = "Vengeance Demon Hunter",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/demon-hunter/vengeance/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility >> Haste = Crit = Versatility >= Mastery", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjZmZkZmZYWMzMjhZMzYGzYmZYGmx2MzYMAAAAAAAQAzMjNAAAAMYMzMzs02MzMAwAAAAYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Haste = Crit = Versatility >= Mastery", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjhZkZmBWMjZwMjZGz8AzMzYYmtZGbjZMGzAAAAAAAIgZmxGAAAAGYmZmZWabmZGAMDAAAgB" },
                { key = "delves", title = "Delves", stats = "Agility >> Haste = Crit = Versatility >= Mastery", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjxMjMzMwiZMDmZMzYmHYGzYMzsNzYbMDGzAAAAAAAIgZmxGAAAAGMzMzMzSbzMzAADAAAgB" },

                -- Update from: https://www.archon.gg/wow/builds/vengeance/demon-hunter/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Haste > Crit > Mastery > Vers", talentCode = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjhZkZmBWMjZwMjZGz8AzMzYYmtZGbjZMGzAAAAAAAAwMzYDAAAADMzMzMLtNzMDAmBAAAwA" },
            },
        },
    },
    DRUID = {
        [102] = {
            title = "Balance Druid",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/druid/balance/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect > Mastery > Crit = Haste > Versatility", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNjxMDMmlZmZmBYYWmZbYGzYjlZMzMjZ2wAgBYZbshpZmlRAAAA2MzMzMYzYYMDgZGAYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Mastery > Haste = Crit > Versatility", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNMmZgxsMzMzMLMgZZmlZWMzMWYZmlxMjxGGAMW2mZwY2GBmAAAAswMzMD2MmxYAAYmBGA" },
                { key = "delves", title = "Delves", stats = "Intellect > Mastery > Crit = Haste > Versatility", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNMmZgxsMzMzMLMgZZmlx2MmxGLzYmZGmFMAYAW2GbYamZbEAAAgNmZmZwmxMGzAYmBAGA" },

                -- Update from: https://www.archon.gg/wow/builds/balance/druid/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Mastery > Haste > Crit > Vers", talentCode = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNjxMDMmlZmZGLMYMmZZmFzMzsMWmZZMzgNMAYssNzgxsNAmAAAAswMzMD2MMGDAAzMwA" },
            },
        },
        [103] = {
            title = "Feral Druid",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/druid/feral/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjZwMzMzMmtlxyMbzYGzMDAAAALBzihxMjaGziZmZGjZYAAAAAAMwAAAAIAY2mZpZbmlNwMDwiZwAAYmBAD" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmZYmZmZMzsZsNz2MzMzDMzAAAAwSwsYMMzomxsYmZmZZMzAAAAAAgBAAAAoZWmtZmZABWAzMALMYAAAMzGG" },
                { key = "delves", title = "Delves", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmZYmZmZMzsZsNz2MzMzDMzAAAAwSwsYMMzomxsYmZmZZMzAAAAAAgBAAAAoZWmtZmZABWAzMALMYAAAMzGG" },

                -- Update from: https://www.archon.gg/wow/builds/feral/druid/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Mastery > Haste > Crit > Vers", talentCode = "CcGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmZYmZmZMzsZsNz2MzMzDMzAAAAwSwsYMMzomxsYmZmZZMzAAAAAAgBAAAAoZWmtZmZAALgZGgFGMAAAmZDD" },
            },
        },
        [104] = {
            title = "Guardian Druid",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/druid/guardian/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility > Haste > Versatility > Crit > Mastery", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmxsMPwYM2MLzMPgZZZgZDGNRzMzyMzMzYMjZAAAAAADLzAAAAQNzysMzMDAgFMzAsYGMYwy2AgZWgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Haste > Versatility > Crit > Mastery", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmZmlhZMziZZMzMWGY2MMaimZmlZmZmZZMDAAAAAAzYZGwy2MDGzyAYKAAAwmxMPAwiZwAWwAMzAYA" },
                { key = "delves", title = "Delves", stats = "Agility > Haste > Versatility > Crit > Mastery", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMjxiZZMPgZZZgZzMGNRzMziZmZmlxMAAAAAAMsNDYZbmBjZZAMFAAAYDz8ADYxMYwgltBYmBwA" },

                -- Update from: https://www.archon.gg/wow/builds/guardian/druid/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Haste > Mastery > Vers > Crit", talentCode = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmZmlhZMziZZMzMWGY2MMaimZmlZmZmZZmZeAAAAAAAzYZGwy2MDGzyAYCAAAYDzAYxMYALYAmZAM" },
            },
        },
        [105] = {
            title = "Restoration Druid",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/druid/restoration/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect > Haste = Mastery > Versatility >> Crit", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMjxMbz2MmZGzywDMmxmxCzAAAAAAAAAAgtBNbMmmhxMmlZmZmhhZGAAAAAAAAstNWw0MzyAAAEwCjZGMzA0MAYmBAMA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Haste > Mastery > Versatility > Crit", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8AMzsMjFbzAAAAAAAAAAglBNbGmmhZMmFzMzMLGegZAAAAAAAwAAQAAAz2MbNbzsYjxMDMzCoZAAmZAYA" },
                { key = "delves", title = "Delves", stats = "Intellect > Haste > Versatility > Crit > Mastery", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMMmxYGzMjZbmZYYhZx2MAAAAAAAAAAYbQzmhpZMzYMLmZmZWmhxAAAAAAAYMAAEAAwws1sMWsBz8AYGLgmBAYmBgB" },

                -- Update from: https://www.archon.gg/wow/builds/restoration/druid/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Mastery > Crit > Vers", talentCode = "CkGAAAAAAAAAAAAAAAAAAAAAAMMmZZMjZmxsN8AMzsMjNbzAAAAAAAAAAglBNbGmmhZMmFzMzMLzgZAAAAAAAwAAAAAgZbmtmlZWsxYmBmZB0MAAzMAMA" },
            },
        },
    },
    EVOKER = {
        [1467] = {
            title = "Devastation Evoker",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/evoker/devastation/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Crit >= Haste = Mastery > Versatility", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzMDMDzYmBMYMTzMzMNjx2MmZmZmHYmZGwMmxYmZZmZgBGDWglxox2AyMIYDDMzghB" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Crit >= Haste = Mastery > Versatility", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzMDgZGmBGGjZaMzMNDz2MmZmZmZmZGwMzMGzMLzMDMwYwCsMGN2GQmBBbYGMzghB" },
                { key = "delves", title = "Delves", stats = "Intellect >> Crit >= Haste = Mastery > Versatility", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwMzMDMDzMMwwYMTjZmpZMzyMmZmZGzMzAmZGDzMLzMDMADWglxox2AyMIYDDMzgZMA" },

                -- Update from: https://www.archon.gg/wow/builds/devastation/evoker/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Crit > Haste > Mastery > Vers", talentCode = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmZgZ8AzwMwwYMTjZmpZM2mxMzMzYmZGwMzMGzMmZGYgxgFYZMasNAmBgNMDmZwwA" },
            },
        },
        [1468] = {
            title = "Preservation Evoker",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/evoker/preservation/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAYmZ2WmHADzMmFjZmZWmxAAAzYGDmxMyMzAAAAMzMTmxMjZbmZAwAjZsxCMwMaoBsAjZGgxA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste >= Mastery = Crit > Versatility", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAMzMz2yADzMmFzYM2mxAAAzYmZmZMMTMmBAAA2mZmJjZmZGjZAAYMjNWgBmRDNMsAzMzAwA" },
                { key = "delves", title = "Delves", stats = "Intellect > Haste > Crit > Versatility > Mastery", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAmZmZ2MwYmZGMzMDbAAAYYMDzYGZmZAAAALzMz0MGzMjZmBAgxM2YDGYGN0gxCMmZAmZA" },

                -- Update from: https://www.archon.gg/wow/builds/preservation/evoker/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Mastery > Haste > Crit > Vers", talentCode = "CwbBAAAAAAAAAAAAAAAAAAAAAAAAAAAMzMz2yADzMmFzYM2mxAAAzYmZGmhZyMmBAAA2mZmJjZmZGjZAAYMjNWgBmhhGGWgZmZAYA" },
            },
        },
        [1473] = {
            title = "Augmentation Evoker",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/evoker/augmentation/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Crit > Haste > Mastery > Versatility", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmZmZbmZmxyAzsMjxwMAAAAAgBAAzMDMYM1YmZGAAAAMjZmxMzyYmBmZzYwCsMGGbDgZiYDzMwMDgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Crit > Haste > Mastery > Versatility", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmZmZbmZmxyAzsMjxwMAAAAAAAAYmBmBjHoGzMzAAAAgZmZmxMz2YmBmZzYwCsMGGbDgZiYDzMDmZAM" },
                { key = "delves", title = "Delves", stats = "Intellect >> Crit > Haste > Mastery > Versatility", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmZmZbmZmxyAzsMjxwMAAAAAAAAYmBmBjHoGzMzAAAAgZmZmxMzyYmBmZzYwCsMGGbDgZiYDzMDmZAM" },

                -- Update from: https://www.archon.gg/wow/builds/augmentation/evoker/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Crit > Haste > Mastery > Vers", talentCode = "CEcBAAAAAAAAAAAAAAAAAAAAAMmZmZbmZmxyAzsMjxwMAAAAAAAAYmBmBjpGzMzAAAAAzMzMmZ2GzMwMbGDWglxwYbAMDiNMzMYmBwA" },
            },
        },
    },
    HUNTER = {
        [253] = {
            title = "Beast Mastery Hunter",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/hunter/beast-mastery/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility > Mastery > Haste > Crit > Versatility", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAAMmxwCsAzwQDbAAYG2GzsNzwMmZYYmxYmxMzYGzwMzYGzghmBAAAAAMDAAAzMzMAzshwwsA2MA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Mastery > Crit > Versatility > Haste", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAYzsNwAGwMsBZsAAgZGLzMDzwMzMYGzMzwMmZGzMzYbmZYMDLDNDAAAAAYGAAAmHYMzwMDQAzCYzA" },
                { key = "delves", title = "Delves", stats = "Agility > Mastery > Crit > Versatility > Haste", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAAMmxwGsAzwQDbAAYGzyMzsYGmZmZGzMMmxMMzMzYGmZGGzMMmmBAAAAAAAAAjxMAzsgglZWAbGA" },

                -- Update from: https://www.archon.gg/wow/builds/beast-mastery/hunter/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Crit > Mastery > Haste > Vers", talentCode = "C0PAAAAAAAAAAAAAAAAAAAAAAYzsNwAGwMsBMWAAwMjlZmhZYmZGMjZmZYGzMjZmZsNzMMmhlhmBAAAAAMDAAAmxYYmBIMMLgFD" },
            },
        },
        [254] = {
            title = "Marksmanship Hunter",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/hunter/marksmanship/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGNWGAzgNAAAAAAAAgZMjZYGzMjZwYaGjZmZbbzMzMMzgZmlxYWGMDAAYMzMDAzMttBDw2wA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGNWGAzgNAAAAAAAAgZMzMjtZMzMmhlx0MGjZ222MzMDzMsMzsMGzywMDAAgxYAYmpNGGgNM" },
                { key = "delves", title = "Delves", stats = "Agility >> Crit > Mastery > Haste > Versatility", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGN2GAzgNAAAAAAAAgZMjZYGzMjZGeATzYMmZbZzMzMMzwyMz2YMbDzMAAgZGDAMz0GWmBYDD" },

                -- Update from: https://www.archon.gg/wow/builds/marksmanship/hunter/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Crit > Mastery > Haste > Vers", talentCode = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGNWGAzgNAAAAAAAAgZMzMjtZMzMmhlx0MGjZ222MzMDzMsMzsMGzywMDAAgxYAYmxGDDwGG" },
            },
        },
        [255] = {
            title = "Survival Hunter",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/hunter/survival/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility > Mastery > Crit > Haste > Versatility", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMgxMG2ILwMM0gFjZmZmxyAAAAAAgZMzMDzYYMDGTzAAAAAAAYZZmZWMzMzMzYMgZ2AMLGjZmNG" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Mastery > Crit > Haste > Versatility", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMgxMG2ILwMM0gFzMzMzwyAAAAAAgZMzMDzYYMDGTzAAAAAGAALLzMziZmZmZGzMgZ2AgxYmZhB" },
                { key = "delves", title = "Delves", stats = "Agility > Mastery > Crit > Haste > Versatility", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMgxMG2ILwMM0gFzMzMzwyAAAAAAgZMzMjtZMMmZYMNDAAAAYAAssMzMbmZmZMjxAmZDAzYMzgB" },

                -- Update from: https://www.archon.gg/wow/builds/survival/hunter/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Mastery > Crit > Haste > Vers", talentCode = "C8PAAAAAAAAAAAAAAAAAAAAAAMgxMG2gFYGGawiZmZmZYZAAAAAAwMzMzMLmxYGzgx0MAAAAgBAwyyMzsYmZmhxYAzsBYYMmZ2YA" },
            },
        },
    },
    MAGE = {
        [62] = {
            title = "Arcane Mage",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/mage/arcane/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery >> Haste > Crit = Versatility", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMzQzMzAAAwAAgAmZmZZZmZYBAgtxMzMmtFLzMzYmxYMzMGLMzMjZAAGAAAzsAAmBADD" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery >> Haste > Crit = Versatility", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFmZGamxAAAwAAgAmZmZZZmJWAAYbYmZMbLWmZmxMjxYmZmxCzMzYGAgBAAwMLAgZAwwA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery >> Haste > Crit = Versatility", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFmZGamxAAAwAAgAmZmZZZmJWAAYbYmZMbLWmZmxMjxYmZmxCzMzYGAgBAAwMLAgZAwwA" },

                -- Update from: https://www.archon.gg/wow/builds/arcane/mage/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Mastery > Haste > Crit > Vers", talentCode = "C4DAAAAAAAAAAAAAAAAAAAAAAMzwMLmZmFMzQzMGAAAGAAAYmZmllZmYBAgtZMzMmNzyMzMmZMGzMzMWYmZmHYAAMAAAmZBAmZAwwA" },
            },
        },
        [63] = {
            title = "Fire Mage",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/mage/fire/cheat-sheet
                { key = "sunfury_raid", title = "Sunfury Raid", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDZmZGAAAGAwMz0sssMDAwmZmx2YmZGAAAAAgFzMzMDAAGzwYmZmZ2GAmZIjxYwMMA" },
                { key = "frostfire_raid", title = "FF Raid", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDZmZGAAAmZZGzMLzCEAAwiZmx2YmZGAAAAAgFzMzMDAAGzYmZmZmZ2AmZADzYMYwA" },
                { key = "sunfury_mythicplus", title = "Sunfury+", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmxAAAwAAmZmmlltZAA2MzM2GzMzYDAAAAAWMzMzMAAYMDjZmZmZbAYmhwYMYGG" },
                { key = "frostfire_mythicplus", title = "FF+", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmxAAAwMLzYmZZWgAAAWMzM2GzMzYBAAAAAWMzMzMAAYMjZmZmZmZDYmBMYMGMYA" },
                { key = "frostfire_delves", title = "FF Delves", stats = "Intellect >> Haste >= Mastery > Versatility >> Crit", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmxAAAwMLzYmZZWgAAAWMzM2GzMzYBAAAAA2MzMzMAAYMjZmZmZmZDYmBMYMGMYA" },

                -- Update from: https://www.archon.gg/wow/builds/fire/mage/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Mastery > Crit > Vers", talentCode = "C8DAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsgZGZmZGAAAGAwMz0sssNDAwmZmx2YmZGbAAAAAwiZmZGAAYMDjZmZmZbAYmBMjxgZYA" },
            },
        },
        [64] = {
            title = "Frost Mage",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/mage/frost/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery >= Crit > Haste >= Versatility", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmxMjZMziZmZmZMDAAAMzMzyyMTbAAAAAAgNA22GzMzgZZeAjZYBAAgZWAmJjBMDGA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery >= Crit > Haste >= Versatility", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAMzwYZmZmFmZmYGmZmZmZWMzMMjZAAAgZmZWWmZaDAAWAAAAWAYbbMzMDmthxMjNAAAmZDYmMGwMYA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery >= Crit > Haste >= Versatility", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMzEzMzMzMzMziZmhZMDAAAMzMzyyMTbAAAAAAgFA22GzMzgZbYMzYDAAgZ2AmJjBMDGA" },

                -- Update from: https://www.archon.gg/wow/builds/frost/mage/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Crit > Mastery > Haste > Vers", talentCode = "CAEAAAAAAAAAAAAAAAAAAAAAAMzwMLzMzsMegZmYmxYmZmZWMzMMjZAAAgZmZWWmZaDAA2AAAAWAYbZMzMDmthxMjNAAAmZDYGYAzgB" },
            },
        },
    },
    MONK = {
        [268] = {
            title = "Brewmaster Monk",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/monk/brewmaster/cheat-sheet
                { key = "raid_def", title = "Raid Def", stats = "Agility >> Crit = Versatility = Mastery > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAgZbzYGPwYWM2mxMDAAAAAAALLYEmBmhxmZMmZmZMzywMmZZYZzy2sMMLAAwysMtMbzsMAAQAmhNwMDYaMAAgB" },
                { key = "mythicplus_std", title = "M+ Std", stats = "Agility >> Crit = Mastery > Versatility > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAwMLbGDzwyM2MmZAAAAAAAYZBmYmBmhBzgZmZGzsNMjZWGW2ssNbzYWAAgNEAAgZbWamZmNG2AYmhpxAGAwA" },
                { key = "delves", title = "Delves", stats = "Agility >> Crit = Versatility = Mastery > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAgZZzYGzwyM2MmZMAAAAAAALLgYmBmhBzgZmZGzsNMjZWGW2ssNbzYWAAglZZaZ2mZZAAgAYYDMzAmGDYAAD" },

                -- Update from: https://www.archon.gg/wow/builds/brewmaster/monk/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Crit > Vers > Mastery > Haste", talentCode = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAwMbbGDGzyM2YmZMAAAAAAALLYEzMwMM2gxMzMDzmtZGzsMssNbbz2wsAAAbAAAgZbWamZmNG2AYmhpxAAAG" },
            },
        },
        [269] = {
            title = "Windwalker Monk",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/monk/windwalker/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility > Haste > Crit >= Mastery >> Versatility", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDjwMMMgZMMzMzwsMMDzyMBAsZmtxwYmZAAsBAzys0MzMLADDMzAwYZMEDYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Haste > Crit >= Mastery >> Versatility", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDzEmhhBMjhZmZGmthZYWmJAgNzsNGGzMDAgNAYWmlmZmZBYYgZGAYZMEDYA" },
                { key = "delves", title = "Delves", stats = "Agility > Haste > Crit >= Mastery >> Versatility", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDzEmhhBMjhZmZGmthZYWmJAgNzsNGGzMDAgNAYWmlmZmZBYYgZGAYZMEDYA" },

                -- Update from: https://www.archon.gg/wow/builds/windwalker/monk/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Haste > Crit > Mastery > Vers", talentCode = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYMghZZmZ2mxAAAAAAAAAAAALDzEmhhBMjhZmZGmthZYWmJAgNzsNGGzMDAgNAYWmlmZmZBYYgZGAYZMgBM" },
            },
        },
        [270] = {
            title = "Mistweaver Monk",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/monk/mistweaver/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Haste > Crit > Versatility >> Mastery", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghx2MwmFzYmZZGbYmZYmlttZGLMjmxMgBDGzyMzMDz2gBLmAAAAAIALWmZZ2mZAAgBMAzAGDjFZMDA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste > Crit > Versatility > Mastery", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMWmZZYxmxMjNstsNjZYmttlZGLMjmxMgBDGzyMzMDzGmhZZmAAAAAIAL2mZZ2mZAAAgBYGwYgFZMDA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Haste > Crit > Versatility > Mastery", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMWmZZML2mxMjNDYMzmZ222mZswQzYGLYwAGzMzMMbDzwsMTAAAAAEgFbzsNbzMAAAwAMDYMMDZMDA" },

                -- Update from: https://www.archon.gg/wow/builds/mistweaver/monk/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Crit > Mastery > Vers", talentCode = "C4QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAghxyMLjZx2MmZsZstsMjZ2Mz2yyMjFGTzYGwgBMmZmZY2wMMLzEAAAAAAsYbmlZbmBAAgBgZAjBWkxMA" },
            },
        },
    },
    PALADIN = {
        [65] = {
            title = "Holy Paladin",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/paladin/holy/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMAAglZmZGzYmZ2YMGzyYbmZxoJGzYmZYY2yAwAG2AbsMjZWmtZmZrBAAAYBA2MMmxMAAgZGmxY0A" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMDAwglxMzMzYmZWgxwyYzMLGNxwYmZYY2yAwAwGYjlZmBABAMzsttYbmhN2GmhNDMjZYAYmBgZMGNA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery > Crit = Haste > Versatility", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMDAwglxMzMzYmZWgxwyYbmZxoJGGmZYY2yAwAwGYjlZmBABAMzsttYbmhN2YgNDMjZYAYmBgZMGNA" },

                -- Update from: https://www.archon.gg/wow/builds/holy/paladin/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Mastery > Crit > Vers", talentCode = "CEEAAAAAAAAAAAAAAAAAAAAAAAAAAYBAMDAwglxMzMzYmZWgxwyYbmZxMNxwYmZYY2yAwAwGYjtZmZWmtZmZrBAAAYhNMYzAzYGAAwMDzYMMA" },
            },
        },
        [66] = {
            title = "Protection Paladin",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/paladin/protection/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength > Haste = Versatility > Crit > Mastery", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsZm5BYWGLzMjZGbLjxYmFbzYAAGAAAAAAkmZWMjZmxYmt2AwAGwgNAAwMTbzMLzAAsBmxAYMDjBAYZGgZGkB" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Haste = Versatility > Crit > Mastery", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsNjBzyYZMjZmZZbMzwsMLzYAAGAAAAAA00MDzYmhhZrNAMwAmBbAAAEgZmltlWmZsYGMAYMDjBAzMAMzMID" },
                { key = "delves", title = "Delves", stats = "Strength > Haste = Versatility > Crit > Mastery", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsNjBzyYZMjZmZZbMzwsMLzYAAGAAAAAA00MziZMzwws1GAGYAzgNAAwMTbzMLzAAsZGMAYMDjBAYZGgZGkB" },

                -- Update from: https://www.archon.gg/wow/builds/protection/paladin/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Haste > Crit > Mastery > Vers", talentCode = "CIEAAAAAAAAAAAAAAAAAAAAAAsZMYWGLzMjZmZZZMzwsMLzYAAAAAAAAgmmZYGzMMMbBADYAD2GAAAAMzsst0yMjFzwMAYMDjBAzMAMzMgB" },
            },
        },
        [70] = {
            title = "Retribution Paladin",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/paladin/retribution/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength > Mastery > Crit > Haste > Versatility", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQz22MzsMMzAAAAAAwoMmhZGbDz2wMbzYMmZYGbsNMAAkZm2mZ2mBAsBYAwYGmBzYMbYZGMMmxgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Mastery > Crit > Haste > Versatility", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAMa22mZmlxMzMDAAAAAwMlhhZGbDz2wMbzYMGDzYjNMAAkZm2mZ2mBAsBYAwYGGYmZYDLzghxMGM" },
                { key = "delves", title = "Delves", stats = "Strength > Mastery > Crit > Haste > Versatility", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQzyyMzsMzMzMDAAAAAwMlxMYGbzY2GmZbGMegZwYjtBAAkZm2mZ2mBAsBYAAzwMYYmZBLzgxMmxgB" },

                -- Update from: https://www.archon.gg/wow/builds/retribution/paladin/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Mastery > Haste > Crit > Vers", talentCode = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQz22MzsMmZmZAAAAAAmpMMMzYbY2GmZbGjxYYGbshBAAmZabmZbGAwGgBAjZYGMjZshlZwwYGDG" },
            },
        },
    },
    PRIEST = {
        [256] = {
            title = "Discipline Priest",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/priest/discipline/cheat-sheet
                { key = "oracle_raid", title = "Oracle Raid", stats = "Intellect > Haste > Crit > Mastery > Versatility", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsAzGjZGzMjZbsNzMzMMDAAAAAAAAAgZYZGMzMDmxMgpZiBYmFMEGzyAMGsAAAjZmZMMzAMzMTzwA" },
                { key = "oracle_mythicplus", title = "Oracle Mythic+", stats = "Intellect > Haste > Crit > Versatility > Mastery", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsYY2YMDzMjZbsNzMzMMDAAAAAAAAAgxYZGMzMjNjZGsZamYAmZBDhxsMAjBLAAwYmZGDmBYmZ0MM" },
                { key = "delve_leveling", title = "Delve/Leveling", stats = "Intellect >> Haste > Crit > Mastery > Versatility", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsYMzGjxYmZMbsNzMzMzAAAAAAAAAAgxYZGMzMjNjZGsZamGwMDACgZZWWAjNDAAjZmZMYGMzAaGG" },

                -- Update from: https://www.archon.gg/wow/builds/discipline/priest/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Crit > Mastery > Vers", talentCode = "CAQAAAAAAAAAAAAAAAAAAAAAAADsYY2YMDzMjZbsNzMzMMDAAAAAAAAAgxYZGMzMjNjZGDmmJGgZWwQYMLDwYwCAAMmZmxgZAmZGmhB" },
            },
        },
        [257] = {
            title = "Holy Priest",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/priest/holy/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Crit > Versatility = Mastery > Haste", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAgZmlxYMzMDzMzYZGmBAAAwwsMDzMzMYGzAYmaAgZWMTmFDAMGsZmZWA0MMjxwMz2yAMDMA" },
                { key = "archon_mythicplus", title = "Archon+", stats = "Intellect >> Versatility > Crit > Haste > Mastery", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAgZzwYWGMmZmZMzMjlZmZAAAAYMWmBzMzYzYmxAmpAAzsZmMbGAYMYzYsAoZMzYMMzstMADYA" },
                { key = "oracle_raid", title = "Oracle Raid", stats = "Intellect >> Crit > Versatility = Mastery > Haste", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAGjZmlZmZMzYYmxYZmxMAAAAGmlZGzMzMMzYGAzUDgZWwQYMbDwYgFGzCgMMPgxwMDwMzMwA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Versatility > Crit > Haste > Mastery", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAAbGGzyYGzMjxMDjlZmZGAAAADzyMjZmZGbGzMmtNMTBAmZxMZ2MAwYwmxYBQDzwYwMLLDwAG" },

                -- Update from: https://www.archon.gg/wow/builds/holy/priest/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Crit > Haste > Mastery > Vers", talentCode = "CEQAAAAAAAAAAAAAAAAAAAAAAwYAAAAAAgZzwYWGMmZmZMzMjlZmZAAAAYMWmBzMzYzYmxAmpAAzsZGmNDAMGsZMWA0MmZMGmZ2WGgBMA" },
            },
        },
        [258] = {
            title = "Shadow Priest",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/priest/shadow/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect > Haste > Mastery > Crit > Versatility", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAgxMMjxyMDzsNzwMsNzMmZmxGyMWMTDwMAzsZGmNDAZMWAwMQGzMzY2GzstMAzED" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Haste > Mastery > Crit > Versatility", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAghZxMGLzMmZWmZYmx2MGzMzYDZGLmpBYGgZ2MDzmBgMGLAYGIjZmZMbjZ2WGgZiB" },
                { key = "delves", title = "Delves", stats = "Intellect > Haste > Mastery > Crit > Versatility", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAghZxMGLzMmZWmZYmx2MGzMzYDZGLmpBYGgZ2MDzmBgMGLAYGIjZmZMbjZ2WGgZiB" },

                -- Update from: https://www.archon.gg/wow/builds/shadow/priest/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Mastery > Crit > Vers", talentCode = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAghZxMGLzMMzyMDzw2MzYmZGbIzYxMNAzAMziZY2MAkxYBAzYgxMzMmtxMbLDwMYA" },
            },
        },
    },
    ROGUE = {
        [259] = {
            title = "Assassination Rogue",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/rogue/assassination/cheat-sheet
                { key = "raid_aoe", title = "Raid AOE", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZMbGMAAAAAwsMYZGAAAAAQbbzMzMzMjxMzMz2MLzMzgZmZmZMzwYAMwCMjRjZBklBsZAwMzgB" },
                { key = "raid_st", title = "Raid ST", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZMbzgBAAAAAmlBLzAAAAAAabbmZmZmZMmZmZ2mZZmZGMmZmZMzYYAMwCMjRjZBklBsZAwMzgB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZmZzgBAAAAAmlBbzAAAAAAabbmZmZmZMmZmZ2mZZmBPwMzMzYYmxYAMwCMjRjZDklBsZsBYmhxA" },
                { key = "delves", title = "Delves", stats = "Agility > Crit > Haste > Mastery > Versatility", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZmZzgBAAAAAmlBbzAAAAAAabbmZmZmZMmZmZ2mZZmBPwMzMzYYmxYA2MLDMglglhJwwixmZGAGD" },

                -- Update from: https://www.archon.gg/wow/builds/assassination/rogue/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Crit > Haste > Mastery > Vers", talentCode = "CMQAAAAAAAAAAAAAAAAAAAAAAYmZmZxAAAAAAwsMYbGAAAAAQbLzMzMzMjxMzMzyMLzM4BmZmZGDzMGDgBWgZMaMbAWGwmxGgZmxYA" },
            },
        },
        [260] = {
            title = "Outlaw Rogue",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/rogue/outlaw/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility >> Haste = Crit > Versatility > mast", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGjZMzsNzMzMjHwswDMzMLTLD2mBAAAAAMbbzMzwMzMzYmZ2GAAAAGADsBzY0Y2AsNhFGAMzMwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Haste = Crit > Versatility > mast", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGzMzMzsNzMzYmHYmFGmx0ygtZAAAAAAz22MzMMzMzMmZmtBAAAgBwAbwMGNmNAbTYhBAzMDM" },
                { key = "delves", title = "Delves", stats = "Agility >> Haste = Crit > Versatility > mast", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGzMzMzsNzMzYmHYmFGmx0ygtZAAAAAAz22MzMMzMzMmZmtBAAAgBwAbwMGNmNAbTYhBAzMDM" },

                -- Update from: https://www.archon.gg/wow/builds/outlaw/rogue/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Crit > Haste > Mastery > Vers", talentCode = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MGzMzMzsNzMzYmHYmFGmx0ygtZAAAAAA2WmZmhZmZmxMzsMAAAAMAGYDmxoxsBYbgFGAMzMDG" },
            },
        },
        [261] = {
            title = "Subtlety Rogue",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/rogue/subtlety/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility > Mastery > 18% Haste >= Crit > Versatility", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMjZwDMzMzYMbjZGbbzMzMzMjBjZ2GAAAAGMGwY2MMwAziWoFbYGwMDmxA" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility > Mastery >> 18% Haste >= Crit > Versatility", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMjZMMzMzYMbzYGbbzMzMzMjBjZ2GAAAAGMGwY2MMwAziWoFbYGwMDmxA" },
                { key = "delves", title = "Delves", stats = "Agility > Mastery > 18% Haste >= Crit > Versatility", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMjZMMzMzYMbzYGbbzMzMzMjBjZ2GAAAAGMGwY2MMwAziWoFbYGwMDmxA" },

                -- Update from: https://www.archon.gg/wow/builds/subtlety/rogue/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Mastery > Crit > Haste > Vers", talentCode = "CUQAAAAAAAAAAAAAAAAAAAAAAAgZ2mBAAAAAmlxYZiZbbMmhZMegZmZGjZbGzYbZMzMzMjBjZ2GAAAAGMGwY2MMwAzCL0iNMDYmBzYA" },
            },
        },
    },
    SHAMAN = {
        [262] = {
            title = "Elemental Shaman",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/shaman/elemental/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Haste = Crit > Versatility", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMbLzMmZmZZbbgxMDAAAAAsYGDbwCMjGasBAzyMzMGbLmwMzyYZmZmxwysMjFzMjZWAAGAzMwwwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery > Haste = Crit > Versatility", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMbLzMzYML2mhZMzAAAAAALmxwGsAzohGbAwsMzMjx2ipNmZMWmZmZMsMLGLmZGzsAAMDwMDMMMA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Mastery > Haste = Crit > Versatility", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMLLzMmZmZbZZMmxMDAAAAYzMbwAGwsxEysAAzyMzMGbLmwMjxyMzMzMjFLGLYMzsAAMAwMjhhB" },

                -- Update from: https://www.archon.gg/wow/builds/elemental/shaman/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Mastery > Crit > Haste > Vers", talentCode = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMbLzMzYML2mhZMzAAAAAALmxwGsAzwQjNAYWmZmxYbx0GzMGLzMzMGWmlZsYmZMzCAwAYmBGGG" },
            },
        },
        [263] = {
            title = "Enhancement Shaman",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/shaman/enhancement/cheat-sheet
                { key = "raid", title = "Raid", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZmZGAAAAAAAAAYB2gZsox2AYmgNAmlZMzMWWmBmZ2YZmZmhhxMAAGgxMTMzAAjB" },
                { key = "mythicplus", title = "Mythic+", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZGzAAAAAAAAAALwGMjFN2GAzEsBwsMjZMWWMwMz2YZmZmZwyYGAAgxYGxMDwgxA" },
                { key = "delves", title = "Delves", stats = "Agility >> Mastery > Haste > Crit > Versatility", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZmZGAAAAAAAAAYB2gZsox2AYmgNAmlZMjxyyMwMjxiZmZGjFmBAAYMmZiZGAYMA" },

                -- Update from: https://www.archon.gg/wow/builds/enhancement/shaman/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Agility > Mastery > Haste > Crit > Vers", talentCode = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMjZmZmZmZmZmZGzAAAAAAAAAALwGMjFN2GAzA2AY2mxMGLLzAzMbjlZmZGGLjZAAAGjZEzMADGD" },
            },
        },
        [264] = {
            title = "Restoration Shaman",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/shaman/restoration/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect > Crit > Versatility = Mastery > Haste", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAzMzMLLbDzMGzMmZGzsYmFYATwswEYsYGmBbjxMNbLzMMjZhFzMzYGmlBAAAmZGAMzADG" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect > Crit > Versatility = Mastery = Haste", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAjZmZbZbYmZGzMGzYmFzsADYCmFmAjFmZGMbzMGNbLzMMjZhFjZGzYZWGAAMAzMDAmZgBD" },
                { key = "delves", title = "Delves", stats = "Intellect > Crit > Versatility = Mastery = Haste", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAjZmxy2MMzMzMzMmxYxMLwAmgZhJwYBzMY2mZmRz2yMDmZwyMmZMjlZBAAGgZmBAzMMGM" },

                -- Update from: https://www.archon.gg/wow/builds/restoration/shaman/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Crit > Haste > Mastery > Vers", talentCode = "CgQAAAAAAAAAAAAAAAAAAAAAAAAAAgBAAAAjZmZbZbGmZmZmZGzYsYmFYADYWYCMWwMDmtZGjmtlZmNzY2YxYmxwysMDAADwYGAMzADG" },
            },
        },
    },
    WARLOCK = {
        [265] = {
            title = "Affliction Warlock",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/warlock/affliction/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Mastery > Crit > Haste > Versatility", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZhhZmZmlBAAYmZxyMzsMzAAjllBGwEMDbBG2GAAAmBAAwMDzMjBGmZmZGzgZmZGAwMwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Mastery > Crit > Haste > Versatility", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMjZGNbmxmZGzyAAAmZmlZzMzyYAgx22ADYCmhtADbDAAAGAAAzMjZMzsNzYGMzMzYYmZmBAMDMA" },
                { key = "open_world", title = "Open World", stats = "Intellect >> Mastery > Crit > Haste > Versatility", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMjZGNbmxmZGzyAAAmZmlZzMzyYAgx22ADYCmhtADbDAAAGAAAzMjZMzsNzYGMzMzYYmZmBAMDMA" },

                -- Update from: https://www.archon.gg/wow/builds/affliction/warlock/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Crit > Mastery > Vers", talentCode = "CkQAAAAAAAAAAAAAAAAAAAAAAwMjZGNbmxmZGzyAAAmZmlZzMzyYAgx22ADYAzwWghtBAAADAAgZmxMmZ2mZMDmZmZMMzMzAAmBG" },
            },
        },
        [266] = {
            title = "Demonology Warlock",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/warlock/demonology/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Haste = Crit > Mastery > Versatility", talentCode = "CoQAy0jxIDofkwJmoH7WhvESoZmZMzoZjhZmxsMAAAAAAAjllZMzMsYYYmtZpNaGbGjZ2mlZmZYAgZYmZmZGMzMzMmZAAAGzMzMDzYZGDYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste = Crit > Mastery > Versatility", talentCode = "CoQAAAAAAAAAAAAAAAAAAAAAAYmhZGNbmx2MzYWGAAAAAAgxyyADYAzwSIjNDGLjZmZmZAgZMzYGgZmZmhZ2AAAzMzMjZGsNzAMA" },
                { key = "delves", title = "Delves", stats = "Intellect >> Haste = Crit > Mastery > Versatility", talentCode = "CoQAAAAAAAAAAAAAAAAAAAAAAYmhZGNbmx2MzYWGAAAAAAgxyyADYAzwSIjNDGLz2MzMmBAmxMzMDwMzMzwMbAAgZmZmxMD2mBwA" },

                -- Update from: https://www.archon.gg/wow/builds/demonology/warlock/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Crit > Haste > Mastery > Vers", talentCode = "CoQAAAAAAAAAAAAAAAAAAAAAAwMjZGNbmZ2mZGzyAAAAAAAAGzYYBGYbYhGWMYsMmZmZmBAmxMjZmZAGzYGbAAgZmZmxMD2mZAGA" },
            },
        },
        [267] = {
            title = "Destruction Warlock",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/warlock/destruction/cheat-sheet
                { key = "raid", title = "Raid", stats = "Intellect >> Haste > Mastery >= Crit > Versatility", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZjhZmZmlZjxMLGjFzAAgZmxMzsAGzYYhMw2wGNWYAAgxAjNAMzAYmxYAAAYmZmBAwMDD" },
                { key = "mythicplus", title = "Mythic+", stats = "Intellect >> Haste > Mastery > Crit > Versatility", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMjZGNLmxiZGzysNzYsYmZZZmBAAzgZmZxCMwsY0YGAzWsxAAAjZYAAwMDGzMmZDAAwMzMDAAzwA" },
                { key = "open_world", title = "Open World", stats = "Intellect >> Haste > Mastery > Crit > Versatility", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZjhZmxsMLjxMLGz2iZAAwMGzMziNYgZzoxMAmtYjBAAGDwCAwMDmZGjZDAAwMzMAAMzwA" },

                -- Update from: https://www.archon.gg/wow/builds/destruction/warlock/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Intellect > Haste > Crit > Mastery > Vers", talentCode = "CsQAAAAAAAAAAAAAAAAAAAAAAwMjZGNLmxmZGzysNzYsYmZZZmBAAzgZmZxCMwsY0YGAzG2YAAgxMMAAYmBjZGzsBAAYmZmBAgZYA" },
            },
        },
    },
    WARRIOR = {
        [71] = {
            title = "Arms Warrior",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/warrior/arms/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength >> Crit > Haste > Mastery > Versatility", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAAzMzsMzMzMDAAAghphxYmxyMzMzgxMDAAAAgZWmZAZMWWGYBMgZYCZGsBMjNz2YwMGgZGAmxwA" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Crit > Haste > Mastery > Versatility", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMzYGAAAghphxwMbLzMzMjZGzMAAAAAGbmB2iBsZGDLwAzoNaMYBYGMGMbmtBzMAgZmhB" },
                { key = "delves", title = "Delves", stats = "Strength >> Crit > Haste > Mastery > Versatility", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMzYGAAAghphxwMbLzMzMjZGzMAAAAAGbmB2iBsZGDLwAzoNaMYBYGMGMbmtBzMAgZmhB" },

                -- Update from: https://www.archon.gg/wow/builds/arms/warrior/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Haste > Crit > Mastery > Vers", talentCode = "CcEAAAAAAAAAAAAAAAAAAAAAAgZmxsMzMzYGAAAghphxwMbLzMzMjZGzMAAAAAGbmB2iBsZGDLwAzwGNGsAMDGDmNz2gZGAwMzwA" },
            },
        },
        [72] = {
            title = "Fury Warrior",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/warrior/fury/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength >> Mastery > Haste > Crit > Versatility", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjxMsMzMzMDjZmZGzMzsMzMGzMbDzMAAQMWWGYBMBzwEYG2AmZ2Y2GAAMzYYMzMMYA" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength >> Mastery > Haste > Crit > Versatility", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjZMz2yMzMjZmxMjZMjZWmZGjZmlxMzAAAhB2glFjGzAysgZsAYGMGAMzAYYmZGMYA" },
                { key = "delves", title = "Delves", stats = "Strength >> Mastery > Haste > Crit > Versatility", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjZMz2yMzMjZmxMjZMjZWmZGjZmlxMzAAAhB2glFjGzAysgZsAYGMGAMzAYYmZGMYA" },

                -- Update from: https://www.archon.gg/wow/builds/fury/warrior/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Haste > Mastery > Crit > Vers", talentCode = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDjZMz2yMzMjZmxMjZMjZWmZGjZmlxMzAAAhB2glFjGzAYWwMWAMDGDAmZAMMzMDGM" },
            },
        },
        [73] = {
            title = "Protection Warrior",
            tabs = {
                -- Update from: https://www.wowhead.com/guide/classes/warrior/protection/cheat-sheet
                { key = "raid", title = "Raid", stats = "Strength > Haste > Crit >= Versatility > Mastery set items = set =", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAA0yAAAzMzYmZGzMzmxsMjxYmGmZYZMzMDzYmBAAAALDAzYAGYDWWMaMDgZLmZDmxMDmtBAzMAAMAD" },
                { key = "mythicplus", title = "Mythic+", stats = "Strength > Haste > Crit >= Versatility > Mastery set items = set =", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAAkBAAGzMzMzMmxsZmZZGjxMNmxwyYmZYmxMDAAAAWGAmxAMwGssY0YGAzWMzGMzMzgZZAwMDAADwA" },
                { key = "delves", title = "Delves", stats = "Strength > Haste > Crit >= Versatility > Mastery set items = set =", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAAkBAAGzYmZmZmxsZmZZYMmpxMGWGzMzwMmZAAAAwyAwMGAYzMG2IDMDL0YmFGzMzMY2GAgZGAwAMA" },

                -- Update from: https://www.archon.gg/wow/builds/protection/warrior/mythic-plus/overview/10/all-dungeons/this-week
                { key = "archon_gg", title = "Archon.gg", stats = "Strength > Haste > Crit > Mastery > Vers", talentCode = "CkEAAAAAAAAAAAAAAAAAAAAAAkBAAGzYmZmZmxsZmZZYMmpxMGWGzMzwMmZAAAAwyYAmxAMwGssY0YGAzGmZDmZmZwsMAYmBAgBYA" },
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
        local currentSpecIndex = GetSpecialization()
        if currentSpecIndex then
            local specInfo = C_SpecializationInfo.GetSpecializationInfo(currentSpecIndex)
            specID = specInfo
        end
    end
    if not specID then
        return nil
    end

    return classRecommendations[specID]
end

local function CreateTalentDialog(parent)
    local dialog = CreateFrame("Frame", "AngusUITalentImportDialog", parent, "BackdropTemplate")
    dialog:SetSize(460, 160)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetFrameLevel(400)
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    dialog:Hide()

    dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dialog.title:SetPoint("TOP", 0, -16)
    dialog.title:SetText("Talent Import String")

    dialog.editBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    dialog.editBox:SetSize(380, 32)
    dialog.editBox:SetPoint("TOP", dialog.title, "BOTTOM", 0, -20)
    dialog.editBox:SetAutoFocus(false)
    dialog.editBox:SetFontObject("ChatFontNormal")
    dialog.editBox:SetTextInsets(8, 8, 0, 0)
    dialog.editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        dialog:Hide()
    end)

    dialog.closeButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    dialog.closeButton:SetSize(120, 24)
    dialog.closeButton:SetPoint("BOTTOM", 0, 16)
    dialog.closeButton:SetText("Close")
    dialog.closeButton:SetScript("OnClick", function()
        dialog:Hide()
    end)

    return dialog
end

local function ShowTalentDialog(dialog, talentCode)
    dialog.editBox:SetText(talentCode or "")
    dialog.editBox:HighlightText()
    dialog:Show()
    dialog.editBox:SetFocus()
end

local function CreateSection(parent, index)
    local section = CreateFrame("Frame", nil, parent)
    section:SetSize(panelWidth, sectionHeight)
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * (sectionHeight + sectionSpacing)))

    section.copyButton = CreateFrame("Button", nil, section, "UIPanelButtonTemplate")
    section.copyButton:SetSize(112, 20)
    section.copyButton:SetPoint("LEFT", 0, 0)

    section.statsText = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    section.statsText:SetPoint("LEFT", section.copyButton, "RIGHT", 8, 0)
    section.statsText:SetPoint("RIGHT", section, "RIGHT", 0, 0)
    section.statsText:SetJustifyH("LEFT")
    section.statsText:SetTextColor(0.9, 0.9, 0.9)

    section:Hide()
    return section
end

local function CreatePanel()
    local classTalentsFrame = GetClassTalentsFrame()
    if not classTalentsFrame then
        return nil
    end

    local panel = CreateFrame("Frame", "AngusUITalentRecommendationsFrame", classTalentsFrame)
    panel:SetSize(panelWidth, 0)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(classTalentsFrame:GetFrameLevel() + 200)
    panel:EnableMouse(true)
    panel.talentDialog = CreateTalentDialog(UIParent)
    panel.sections = {}

    return panel
end

local function EnsureSectionCount(panel, sectionCount)
    while #panel.sections < sectionCount do
        local section = CreateSection(panel, #panel.sections + 1)
        section.talentDialog = panel.talentDialog
        table.insert(panel.sections, section)
    end
end

function AngusUI:TalentRecommendationsRefresh()
    local classTalentsFrame = GetClassTalentsFrame()
    if not classTalentsFrame then
        return
    end

    local specRecommendation = GetCurrentRecommendation()
    local panel = _G["AngusUITalentRecommendationsFrame"] or CreatePanel()
    if not panel then
        return
    end

    if not specRecommendation then
        panel:Hide()
        return
    end

    panel.specRecommendation = specRecommendation
    local tabCount = #specRecommendation.tabs
    EnsureSectionCount(panel, tabCount)
    panel:SetHeight(GetPanelHeight(tabCount))
    panel:ClearAllPoints()
    panel:SetPoint("BOTTOM", classTalentsFrame, "BOTTOM", panelOffsetX, panelBottomOffset)

    for index, section in ipairs(panel.sections) do
        local tabData = specRecommendation.tabs[index]
        if tabData then
            section.copyButton:SetText(tabData.title)
            section.copyButton:SetScript("OnClick", function()
                ShowTalentDialog(panel.talentDialog, tabData.talentCode)
            end)
            section.statsText:SetText(tabData.stats or "")
            section:Show()
        else
            section:Hide()
        end
    end

    panel:Show()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
eventFrame:SetScript("OnEvent", function(_, _, unit)
    if unit and unit ~= "player" then
        return
    end

    AngusUI:TalentRecommendationsRefresh()
end)
