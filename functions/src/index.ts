import {setGlobalOptions} from "firebase-functions";

import {FUNCTIONS_REGION} from "./config/constants.js";

setGlobalOptions({
  maxInstances: 10,
  region: FUNCTIONS_REGION,
});

export {
  getBattleLog,
  getPlayer,
  getUpcomingChests,
  syncPlayer,
} from "./functions/player.functions.js";
