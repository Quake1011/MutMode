#include <sourcemod>
#include <cstrike>
#include <sdktools>

float orig[MAXPLAYERS+1][3];
float angl[MAXPLAYERS+1][3];

bool IsActiveHudEvent[MAXPLAYERS+1];

bool bTarget[MAXPLAYERS+1][MAXPLAYERS+1];

public Plugin myinfo =
{
    name = "MutMode",
    author = "Quake1011",
    description = "Mutual teams mode",
    version = "1.0",
    url = "https://github.com/Quake1011/"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_offEv", Cmd_offEvent);

    HookEvent("player_death", EventPlayerDeath, EventHookMode_Pre);
    HookEvent("round_start", EventRoundStart, EventHookMode_Post);
}

public void OnClientDisconnect_Post(client)
{
    orig[client] = NULL_VECTOR;
    for(int i = 0;i <= MAXPLAYERS;i++)
    {
        bTarget[client][i+i] = false;
    }
    
}

public Action Cmd_offEvent(int client, int args)
{
    if(IsActiveHudEvent[client])
    {
        IsActiveHudEvent[client]=false;
    }
    else IsActiveHudEvent[client]=true;
    return Plugin_Continue;
}

public Action EventPlayerDeath(Event event, const char[] sEvent, bool bDontBroadCast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int client = GetClientOfUserId(event.GetInt("userid"));
    int team;
    switch(GetClientTeam(client))
    {
        case 2: 
        {
            team = CS_TEAM_T;
            ChangeClientTeam(client, team);
        }
        case 3:
        {
            team = CS_TEAM_CT;
            ChangeClientTeam(client, team);
        }
    }
    SetEntProp(client, Prop_Send, "m_iHealth", 100);
    TeleportOnSpawn(client);
    StartKillerEvent(client, attacker);

    if(bTarget[client][attacker] == true) bTarget[client][attacker] = false;

    return Plugin_Continue;
}

public void StartKillerEvent(int client, int attacker)
{
    if(!IsActiveHudEvent[client])
    {
        char buffer[256];
        Format(buffer, sizeof(buffer), "Последний убийца: %N\nУбейте его, что получить 100hp\nПосле смерти цель пропадет", attacker);
        SetHudTextParams(0.005, 0.9, 1.1, 255 , 255, 255, 255, 2, 0.0 , 0.0, 0.0);
        ShowHudText(client, -1, buffer);
        bTarget[client][attacker] = true;
    }
}

void TeleportOnSpawn(client)
{
    GetClientAbsOrigin(client, orig[client]);
    GetClientAbsAngles(client, angl[client]);
    CS_RespawnPlayer(client);
    TeleportEntity(client, orig[client], angl[client], NULL_VECTOR);
}

public Action EventRoundStart(Event event, const char[] sEvent, bool bDontBroadCast)
{
    int iCount = 0;
    if(GetMaxAlivePlayers(0) % 2 == 0)
    {
        iCount = GetMaxAlivePlayers(0)/2;
        for(int i = 0 ;i<2;i++)
        {
            for(int j = 0;j < iCount; j++)
            {
                ChangeClientTeam(j, CS_TEAM_T+i);
            }
        } 
    }
    else
    {
        int c = 0;
        iCount = GetMaxAlivePlayers(0)/2;
        for(int i = 0 ;i<2;i++)
        {
            for(int j = 0;j < iCount; j++)
            {
                ChangeClientTeam(j, CS_TEAM_T+i);
                c=j;
            }
        }
        ChangeClientTeam(c+1, GetRandomInt(2,3));
    }
    return Plugin_Continue;
}

int GetMaxAlivePlayers(int num)
{
    int k;
    for(int i = 0;i <= MaxClients; i++)
    {
        if(!IsFakeClient(i) && IsClientInGame(i) && !IsClientSourceTV(i) && IsPlayerAlive(i) && !IsClientObserver(i))
        {
            if(num == 0)
            {
                i++;
            }
            else
            {
                if(num == 2 && GetClientTeam(i) == 2)
                {
                    i++;
                }
                else if(num == 3 && GetClientTeam(i) == 3)
                {
                    i++;
                }
            }
        }
        k=i;
    }
    return k;
}
