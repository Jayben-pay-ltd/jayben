const admin = require("firebase-admin");
admin.initializeApp();

require('./src/transaction_functions.js')(exports);
require('./src/deposit_functions_v1.js')(exports);
require('./src/deposit_functions_v2.js')(exports);
require('./src/daily_cron_scheduler.js')(exports);
require('./src/migration_functions.js')(exports);
require('./src/jayben_points_api.js')(exports);
require('./src/database_backups.js')(exports);
require('./src/user_functions.js')(exports);
require('./src/feed_functions.js')(exports);
require('./src/auth_functions.js')(exports);
require('./src/admin_metrics.js')(exports);
require('./src/sms_functions.js')(exports);
require('./src/virtual_cards.js')(exports);
require('./src/notifications.js')(exports);
require('./src/merchant_api.js')(exports);
require('./src/swf_groups.js')(exports);
