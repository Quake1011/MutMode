#include <sourcemod>
#include <cstrike>
#include <sdktools>

float orig[MAXPLAYERS+1][3];
float angl[MAXPLAYERS+1][3];

public void OnPluginStart()
{
    HookEvent("player_death", EventPlayerDeath, EventHookMode_Pre);
    HookEvent("round_start", EventRoundStart, EventHookMode_Post);
}

public void OnClientDisconnect_Post(client)
{
    orig[client]=NULL_VECTOR;
}

public Action EventPlayerDeath(Event event, const char[] sEvent, bool bDontBroadCast)
{
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
    return Plugin_Continue;
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