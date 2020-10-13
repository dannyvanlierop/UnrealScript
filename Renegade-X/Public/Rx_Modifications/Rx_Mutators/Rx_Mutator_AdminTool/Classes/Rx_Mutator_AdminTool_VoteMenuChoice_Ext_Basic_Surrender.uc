class Rx_Mutator_AdminTool_VoteMenuChoice_Ext_Basic_Surrender extends Rx_Mutator_AdminTool_VoteMenuChoice_Ext_Basic;

function Init()
{
	ToTeam = Handler.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
	Finish();
}

function string ComposeTopString()
{
	return super.ComposeTopString() $ " is calling for a surrender";
}

function Execute(Rx_Game game)
{
	switch(ToTeam)
	{
		case 0:
		game.BeginSurrender(1);
		break;
		
		case 1:
		game.BeginSurrender(0);
		break;
		
		default: 
		game.EndRxGame("Surrender", 255);
		break;
	}
	
}

DefaultProperties
{
	PercentYesToPass=0.20f
	MenuDisplayString = "Surrender"
}