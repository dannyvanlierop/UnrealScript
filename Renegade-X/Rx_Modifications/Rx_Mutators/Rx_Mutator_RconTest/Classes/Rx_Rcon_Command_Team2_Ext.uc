class Rx_Rcon_Command_Team2_Ext extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local Rx_PRI PRI;
	local UTTeamInfo Team;
	local float credits;
	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	PRI = Rx_Game(`WorldInfoObject.Game).ParsePlayer(parameters, parameters);
	if (PRI == None)
		return parameters;

	if (Controller(PRI.Owner) == None) 
		return "Error: Player has no controller!";

	// Hey, maybe there'll be more than 2 teams in the future. -shrugs-
	if (PRI.GetTeamNum() + 1 == ArrayCount(Rx_Game(`WorldInfoObject.Game).Teams))
		Team = Rx_Game(`WorldInfoObject.Game).Teams[0];
	else
		Team = Rx_Game(`WorldInfoObject.Game).Teams[PRI.GetTeamNum() + 1];

	credits = PRI.GetCredits();
	Rx_Game(`WorldInfoObject.Game).SetTeam(Controller(PRI.Owner), Team, true);
	if (Controller(PRI.Owner).Pawn != None)
		Controller(PRI.Owner).Pawn.Destroy();
	PRI.SetCredits(credits);

	return "";
}

function string getHelp(string parameters)
{
	return "Changes a player's team, without resetting their credits." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("team");
	triggers.Add("changeteam");
	Syntax="Syntax: Team Player[String]";
}