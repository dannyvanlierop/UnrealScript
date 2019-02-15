/*******************************************************************************
 * Rx_Mutator_Deck_Pawn generated by Eliot.UELib using UE Explorer.
 * Eliot.UELib ? 2009-2015 Eliot van Uytfanghe. All rights reserved.
 * http://eliotvu.com
 *
 * All rights belong to their respective owners.
 *******************************************************************************/
class Rx_Mutator_Deck_Pawn extends Rx_Pawn
    config(Game)
    hidecategories(Navigation);

var bool canDJ;
var AnimNodeBlendBySpeed SpeedConNode;
var float DefGroundSpeed;

function bool DoJump(bool bUpdating)
{
    canDJ = true;

    if(JumpZ < default.JumpZ)
    {
        JumpZ = default.JumpZ;
    }
    CurrentHopStamina = 1.0;

    if(Abs(Velocity.Z) < DoubleJumpThreshold)
    {
        LogInternal("In doublejump threshhold");
    }

    if(((!bUpdating && CanDoubleJump()) && Abs(Velocity.Z) < DoubleJumpThreshold) && IsLocallyControlled())
    {

        if(Rx_Controller(Controller) != none)
        {
            Rx_Controller(Controller).bDoubleJump = true;
        }
        LogInternal("222222222222222222222222DJump N Node Single:" $ string(Rx_Controller(Controller).bDoubleJump));
        DoDoubleJump(bUpdating);
        MultiJumpRemaining -= 1;
        return true;
    }

    if(((bJumpCapable && !bIsCrouched) && !bWantsToCrouch) && ((Physics == 1) || Physics == 9) || Physics == 8)
    {

        if(Physics == 8)
        {
            Velocity = JumpZ * Floor;
        }

        else
        {

            if(Physics == 9)
            {
                Velocity.Z = 0.0;
            }

            else
            {

                if(bIsWalking)
                {
                    Velocity.Z = default.JumpZ;
                }

                else
                {
                    Velocity.Z = JumpZ;
                }
            }
        }

        if(((Base != none) && !Base.bWorldGeometry) && Base.Velocity.Z > 0.0)
        {

            if((WorldInfo.WorldGravityZ != WorldInfo.DefaultGravityZ) && (GetGravityZ()) == WorldInfo.WorldGravityZ)
            {
                Velocity.Z += (Base.Velocity.Z * Sqrt((GetGravityZ()) / WorldInfo.DefaultGravityZ));
            }

            else
            {
                Velocity.Z += Base.Velocity.Z;
            }
        }
        SetPhysics(2);
        bReadyToDoubleJump = true;
        canDJ = CanDoubleJump();
        LogInternal("SingleJump _ VarbUpdating:" $ string(bUpdating));
        bDodging = false;
        canDJ = ((!bUpdating && CanDoubleJump()) && Abs(Velocity.Z) < DoubleJumpThreshold) && IsLocallyControlled();
        LogInternal("CanDJ0000000000NormalJump:" $ string(canDJ));

        if(!bUpdating)
        {
            PlayJumpingSound();
        }
        return true;
    }
    return false;

}

simulated function DoDoubleJump(bool bUpdating)
{

    if(!bIsCrouched && !bWantsToCrouch)
    {

        if(!IsLocallyControlled() || AIController(Controller) != none)
        {
            MultiJumpRemaining -= 1;
        }
        Velocity.Z = JumpZ + float(MultiJumpBoost);
        LogInternal("01010101110101DoneDid A Double Jump");
        Rx_InventoryManager(InvManager).OwnerEvent('MultiJump');
        SetPhysics(2);
        BaseEyeHeight = DoubleJumpEyeHeight;

        if(!bUpdating)
        {
            SoundGroupClass.static.PlayDoubleJumpSound(self);
        }
    }
  
}

function bool CanDoubleJump()
{
    return ((MultiJumpRemaining > 0) && Physics == 2) && bReadyToDoubleJump || UTBot(Controller) != none;

}

function bool CanMultiJump()
{
    return MaxMultiJump > 0;

}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if(SkelComp == Mesh)
    {

        foreach SkelComp.AllAnimNodes(class'AnimNodeBlendBySpeed', SpeedConNode)
        {
            SpeedConNode.Constraints[0] = 0.0;
            SpeedConNode.Constraints[1] = 100.0;
            SpeedConNode.Constraints[2] = 250.0;
            SpeedConNode.Constraints[3] = 550.0;
        }        
    }
    //return;    
}

simulated event Destroyed()
{
    super.Destroyed();
    SpeedConNode = none;

}

function RemoteDropFrom(Vector StartLocation, Vector StartVelocity, Rx_Weapon Weap)
{
    local DroppedPickup P;

    LogInternal("Start function RemoteDropFrom");

    if(InvManager != none)
    {
        InvManager.RemoveFromInventory(Weap);
    }

    if((Weap.DroppedPickupClass == none) || Weap.DroppedPickupMesh == none)
    {
        Weap.Destroy();
        return;
    }
    Weap.GotoState('Inactive');
    Weap.ForceEndFire();
    Weap.DetachWeapon();
    P = Spawn(Weap.DroppedPickupClass,,, StartLocation);

    if(P == none)
    {
        Weap.Destroy();
        return;
    }
    P.SetPhysics(2);
    P.Inventory = Weap;
    P.InventoryClass = Weap.Class;
    P.Velocity = StartVelocity;
    P.Instigator = self;
    P.SetPickupMesh(Weap.DroppedPickupMesh);
    P.SetPickupParticles(Weap.DroppedPickupParticles);
    GotoState('None');
    //return;    
}

function bool Died(Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
    LogInternal("Start function bool died");

    if(Weapon != none)
    {
        RemoteDropFrom(Location, Velocity, Rx_Weapon(Weapon));
    }
    super.Died(Killer, DamageType, HitLocation);
    return true;

}

defaultproperties
{

}