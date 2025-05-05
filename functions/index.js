const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { getFirestore } = require("firebase-admin/firestore");

admin.initializeApp();
const db = getFirestore();
const messaging = admin.messaging();

const sendNotificationToAllUsers = async () => {
  try {
    console.log("🚀 Iniciando envío de notificaciones a todos los usuarios...");

    // Consulta tipo collectionGroup para obtener todos los documentos de todas las subcolecciones "account"
    const accountDocsSnapshot = await db.collectionGroup("account").get();

    console.log(`📚 Se encontraron ${accountDocsSnapshot.size} cuentas en Firestore.`);

    const tokens = [];

    for (const doc of accountDocsSnapshot.docs) {
      const data = doc.data();
      const token = data.token;

      if (token && token.trim() !== "") {
        tokens.push(token);
      } else {
        console.log(`⚠️ Documento ${doc.ref.path} tiene token vacío o indefinido.`);
      }
    }

    console.log(`✅ Se recolectaron ${tokens.length} tokens válidos.`);

    if (tokens.length === 0) {
      console.log("⛔ No hay tokens válidos para enviar notificaciones.");
      return;
    }

    const message = {
      notification: {
        title: "📅 Recordatorio de hábitos - Stu-Bit",
        body: "No olvides realizar tus hábitos asignados para hoy. ¡Tú puedes! 💪",
      },
      tokens: tokens,
    };

    const response = await messaging.sendEachForMulticast(message);
    console.log(`📤 Notificaciones enviadas. Éxitos: ${response.successCount}, Fallos: ${response.failureCount}`);

    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        console.log(`❌ Fallo en el token ${tokens[idx]}:`, resp.error);
      }
    });

  } catch (error) {
    console.error("🔥 Error general en el envío de notificaciones:", error);
  }
};

// Programación de tareas
exports.scheduledNotification1 = onSchedule(
  {
    schedule: "0 8 * * *", // 08:00 AM todos los días
    timeZone: "America/Mexico_City",
  },
  async () => {
    console.log("⏰ Ejecutando tarea programada: 8:00 AM");
    await sendNotificationToAllUsers();
  }
);

exports.scheduledNotification2 = onSchedule(
  {
    schedule: "0 17 * * *", // 05:00 PM todos los días
    timeZone: "America/Mexico_City",
  },
  async () => {
    console.log("⏰ Ejecutando tarea programada: 5:00 PM");
    await sendNotificationToAllUsers();
  }
);

exports.scheduledNotification3 = onSchedule(
  {
    schedule: "0 23 * * *", // 11:00 PM todos los días
    timeZone: "America/Mexico_City",
  },
  async () => {
    console.log("⏰ Ejecutando tarea programada: 11:00 PM");
    await sendNotificationToAllUsers();
  }
);
