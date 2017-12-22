using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Practices.EnterpriseLibrary.Logging;
using Microsoft.Practices.EnterpriseLibrary.Logging.ExtraInformation;

namespace GeoLib
{
    class LoggingFactory
    {
        /// <summary>
        /// 取得Information LogEntry 物件 Instance
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static LogEntry GetInformationLogEntry(object obj)
        {
            LogEntry log = new LogEntry();
            log.EventId = 1;
            log.Priority = 5;
            log.Title = "Information Log ";
            log.Message = "Information Body";
            //使用app.config/web.config裡的AppLog
            log.Categories.Add("AppLog");
            log.Severity = System.Diagnostics.TraceEventType.Information;
            if (obj != null)
            {
                Dictionary<string, object> dictionary = new Dictionary<string, object>();
                dictionary.Add("Execution Class:", obj);
                log.ExtendedProperties = dictionary;
            }
            return log;
        }

        /// <summary>
        /// 取得Debug LogEntry 物件 Instance
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static LogEntry GetDebugLogEntry(object obj)
        {
            LogEntry log = new LogEntry();
            log.EventId = 3;
            log.Priority = 2;
            log.Title = "Debug Log ";
            log.Message = "Debug Body";
            //使用app.config/web.config裡的AppLog
            log.Categories.Add("AppLog");
            log.Severity = System.Diagnostics.TraceEventType.Information;
            if (obj != null)
            {
                Dictionary<string, object> dictionary = new Dictionary<string, object>();
                dictionary.Add("Execution Class:", obj);
                log.ExtendedProperties = dictionary;
            }
            return log;
        }

        /// <summary>
        /// 取得Error LogEntry 物件 Instance
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static LogEntry GetErrorLogEntry(object obj)
        {
            LogEntry log = new LogEntry();
            log.EventId = 2;
            log.Priority = 8;
            log.Title = "Error Log ";
            log.Message = "Error Body";
            //使用app.config/web.config裡的AppLog
            log.Categories.Add("AppLog");
            log.Severity = System.Diagnostics.TraceEventType.Error;
            if (obj != null)
            {
                Dictionary<string, object> dictionary = new Dictionary<string, object>();
                dictionary.Add("Execution Class:", obj);
                log.ExtendedProperties = dictionary;
            }
            return log;
        }
    }
}
