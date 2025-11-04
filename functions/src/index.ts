import {setGlobalOptions} from "firebase-functions";
import {sendAlertToTrustedContacts} from "./notifyTrustedContacts";

setGlobalOptions({maxInstances: 10});

export {
  sendAlertToTrustedContacts,
};
