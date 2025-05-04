const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Función para enviar notificación a un token específico
const sendManualNotification = async () => {
  // Este es el token que deseas probar manualmente
  const token = "fm4PKD3OTjGf_k16I7xKHy:APA91bGxwkosuwVc3XHrW7GBbT9kUvmZ74jDIsyCFWS-mjKVg2dKkqbYwsSPNPPwpPra5-4WyD4A6C2HgI0OqreX-VdhfrbXtuJi3uUHedsypdEtXfUbaPk";
  
  // Crear el mensaje de notificación
  const message = {
    token: token,
    notification: {
      title: "¡Hola desde Stu-Bit!",
      body: "Este es tu recordatorio diario. 📚",
    },
  };

  try {
    // Enviar la notificación manualmente
    const response = await messaging.send(message);
    console.log("📤 Notificación enviada con éxito al token manual:", response);
  } catch (error) {
    console.error("🔥 Error en el envío de notificación manual:", error);
  }
};

// Función para obtener e imprimir el token desde Firestore
const logUserToken = async () => {
  // Obtener el primer documento de la colección "user_data"
  const userDocs = await db.collection("user_data").limit(1).get();
  
  if (userDocs.empty) {
    console.log("⚠️ No se encontraron usuarios en la colección 'user_data'.");
    return;
  }

  // Acceder al primer usuario encontrado
  const userDoc = userDocs.docs[0];
  const accountSubcollection = await userDoc.ref.collection("account").limit(1).get();

  if (accountSubcollection.empty) {
    console.log("⚠️ No se encontró la subcolección 'account' para el usuario.");
    return;
  }

  // Accedemos al primer documento de la subcolección 'account'
  const accountDoc = accountSubcollection.docs[0];
  const token = accountDoc.data().token;

  // Imprimir el token encontrado en los logs
  if (token) {
    console.log(`🟢 Token encontrado para el usuario ${userDoc.id}: ${token}`);
  } else {
    console.log("⚠️ No se encontró token en el documento de la cuenta.");
  }
};

// Programar la tarea para enviar la notificación 1 y logear el token
exports.scheduledNotification1 = onSchedule(
  {
    schedule: "52 20 * * *", // Esto ejecutará la función todos los días a las 8:30 PM (hora local)
    timeZone: "America/Mexico_City",
  },
  async () => {
    await logUserToken();  // Loguear el token
    await sendManualNotification();  // Enviar la notificación al token manual
  }
);

// Programar la tarea para enviar la notificación 2 y logear el token
exports.scheduledNotification2 = onSchedule(
  {
    schedule: "54 20 * * *", // Esto ejecutará la función todos los días a las 8:30 PM (hora local)
    timeZone: "America/Mexico_City",
  },
  async () => {
    await logUserToken();  // Loguear el token
    await sendManualNotification();  // Enviar la notificación al token manual
  }
);

// Programar la tarea para enviar la notificación 3 y logear el token
exports.scheduledNotification3 = onSchedule(
  {
    schedule: "59 20 * * *", // Esto ejecutará la función todos los días a las 8:33 PM (hora local)
    timeZone: "America/Mexico_City",
  },
  async () => {
    await logUserToken();  // Loguear el token
    await sendManualNotification();  // Enviar la notificación al token manual
  }
);
