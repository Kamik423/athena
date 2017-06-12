// CREATED BY HANS SCHÜLEIN


// SETUP
SET landingpad TO SHIP:GEOPOSITION.
SET controllerheight TO SHIP:ALTITUDE - landingpad:TERRAINHEIGHT.
LOCK h_d TO SHIP:ALTITUDE - landingpad:TERRAINHEIGHT - controllerheight.
LOCK suicide_burn_altitude TO 0.5 * ( SHIP:VERTICALSPEED ^ 2 / (SHIP:MAXTHRUST / SHIP:MASS - 9.81)) - SHIP:VERTICALSPEED/CONFIG:IPU.
LOCK distance_to_suicide_burn TO h_d - suicide_burn_altitude.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


FUNCTION countdown {
    PARAMETER seconds.

    CLEARSCREEN.
    FROM {LOCAL counter is seconds.} UNTIL counter = 0 STEP {SET counter TO counter - 1.} DO {
        PRINT counter + "  " AT (0,0).
        WAIT 1.
    }
}


FUNCTION launch {
    LOCK THROTTLE TO 1.
    LOCK STEERING TO UP.
    STAGE.
    PRINT("LAUNCH").
}


FUNCTION straight_ascent {
    PARAMETER burn_time.

    WAIT burn_time.
    LOCK THROTTLE TO 0.
    PRINT("SHUTDOWN").
    WAIT UNTIL SHIP:VERTICALSPEED < 0.
    PRINT("APOAPSIS").
}


FUNCTION suicide_straight {
    WAIT UNTIL distance_to_suicide_burn < 0.
    PRINT("SUICIDE BURN IGNITION").
    RCS ON.
    LOCK THROTTLE TO 1 - 0.05 * distance_to_suicide_burn.
    LOCK STEERING TO UP.
    IF NOT GEAR { TOGGLE GEAR.}
}


FUNCTION deactivation {
    WAIT UNTIL SHIP:VERTICALSPEED > 0.
    PRINT("TOUCHDOWN").
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    RCS OFF.
    PRINT("SHUTDOWN").
    SHUTDOWN.
}



countdown(10).
launch().
straight_ascent(4).
suicide_straight().
deactivation().
