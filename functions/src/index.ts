import {setGlobalOptions} from "firebase-functions";

import {FUNCTIONS_REGION} from "./config/constants.js";
import {initAdminApp} from "./config/firebase.js";

// Ensure Admin SDK is ready before any callable handler runs.
initAdminApp();

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
