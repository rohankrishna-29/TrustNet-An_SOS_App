import {setGlobalOptions} from "firebase-functions";
import {sendAlertToTrustedContacts} from "./notifyTrustedContacts";
import { detectNearbyUsers } from "./nearbyUsers";

setGlobalOptions({maxInstances: 10});

export {
  sendAlertToTrustedContacts,
  detectNearbyUsers,
};
