#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
    /* Game Rules */
    setDvar("scr_sd_roundswitch", 1);
    setDvar("scr_sd_defusetime", 7.5);
    setDvar("scr_sd_winlimit", 8);
    setDvar("scr_sd_timelimit", 2.5);
    level thread onPlayerConnect();
    level thread smoothEndGame();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
        player thread watchLoadout();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self iPrintln("IW4: [^1Gamebattles^7]");
    }
}

watchLoadout()
{
    self thread watchWeapons();
    self thread watchEquipment();
}

watchWeapons()
{
    /* Disallowed Weapons*/
    for(;;)
    {
        self waittill("weapon_change", newWeapon);
        if(weaponClass(newWeapon) == "rocketlauncher" || weaponClass(newWeapon) == "spread" || isSubStr(newWeapon, "fal") || isSubStr(newWeapon, "rpd") || isSubStr(newWeapon, "m16_eotech"))
        {
            if(newWeapon == self.primaryWeapon)
                replacementWeapon = "ump45_mp";
            else
                replacementWeapon = "tmp_mp";
            
            self takeWeapon(newWeapon);
            self giveWeapon(replacementWeapon);
            self setSpawnWeapon(replacementWeapon);

            self iPrintln("Diallowed Weapon: [^1" + newWeapon + "^7] Replaced With: [^2" + replacementWeapon + "^7]");
        }
    }
}

/* Disallowed Equipment */
watchEquipment()
{
    for(;;)
    {
        self waittill("grenade_fire", grenade, weapon);
        wait 0.1;
        if(isSubStr(weapon, "c4"))
        {
            for(i = 0; i < self.c4array.size; i++)
            {
                if(isDefined(self.c4array[i]))
                    self.c4array[i] destroy();
            }
        }
        else if(isSubStr(weapon, "claymore"))
        {
            for(i = 0; i < self.claymorearray.size; i++)
            {
                if(isDefined(self.claymorearray[i]))
                    self.claymorearray[i] destroy();
            }
        }
    }
}

smoothEndGame()
{
    level waittill("game_ended");
    wait 0.25;
    lerpValue = 1;
    for(i = 0; i <= 4; i++)
    {
        lerpValue -= (0.15);
        setSlowMotion(1.0, lerpValue, 0);
        wait 0.1;
    }
    wait 0.35;
    for(i = 0; i <= 4; i++)
    {
        lerpValue += (0.15);
        setSlowMotion(0.25, lerpValue, 0);
        wait .085;
    }
}