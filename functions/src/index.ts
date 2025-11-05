import {setGlobalOptions} from "firebase-functions";
import {sendAlertToTrustedContacts} from "./notifyTrustedContacts";
import { sendRedAlertNotificationsToNearbyUsers } from "./sendRedAlertNotificationsToNearbyUsers";

setGlobalOptions({maxInstances: 10});

export {
  sendAlertToTrustedContacts,
  sendRedAlertNotificationsToNearbyUsers,
};
