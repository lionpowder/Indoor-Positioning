using Microsoft.Practices.EnterpriseLibrary.Logging;
using Microsoft.Practices.EnterpriseLibrary.Logging.ExtraInformation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GeoLib
{
    public class CommonLogger : LogWriterFactory
    {
        /* Logwriter 物件*/
        private static LogWriter logWriter = new LogWriterFactory().Create();

        /// <summary>
        /// 記錄Information
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="msg"></param>
        public static void LogInformation(object obj, string msg)
        {
            LogEntry log = LoggingFactory.GetInformationLogEntry(obj);
            log.Message = msg;
            Log(log);
        }

        /// <summary>
        /// 記錄Error
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="msg"></param>
        /// <param name="e"></param>
        /// <param name="extendedProperties"></param>
        /// <param name="extendedValue"></param>
        public static void LogError(object obj, string msg, System.Exception e, Dictionary<string, string> extendedValue)
        {
            LogEntry log = LoggingFactory.GetErrorLogEntry(obj);
            log.Message = msg;
            log.ExtendedProperties.Add("Failure", e);

            foreach (string property in extendedValue.Keys)
            {
                string va = "";
                extendedValue.TryGetValue(property, out va);
                log.ExtendedProperties.Add(property, va);
            }

            Log(log);
        }

        /// <summary>
        /// 記錄Error
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="msg"></param>
        /// <param name="e"></param>
        public static void LogError(object obj, string msg, System.Exception e)
        {
            LogEntry log = LoggingFactory.GetErrorLogEntry(obj);
            log.Message = msg;
            log.ExtendedProperties.Add("Failure", e);
            Log(log);
        }

        /// <summary>
        /// 記錄Debug
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="msg"></param>
        public static void LogDebug(object obj, string msg)
        {
            LogEntry log = LoggingFactory.GetDebugLogEntry(obj);
            log.Message = msg;
            Log(log);
        }

        private static void Log(LogEntry log)
        {
            AddExtendedProperty(log);
            logWriter.Write(log);
        }

        private static void AddExtendedProperty(LogEntry log)
        {
            if (log.Severity == System.Diagnostics.TraceEventType.Error || log.Severity == System.Diagnostics.TraceEventType.Critical)
            {
                Dictionary<string, object> dictionary = new Dictionary<string, object>();
                foreach (KeyValuePair<string, object> keyValue in log.ExtendedProperties)
                {
                    dictionary.Add(keyValue.Key, keyValue.Value);
                }
                DebugInformationProvider infoProvider = new DebugInformationProvider();

                //呼叫DebugInformationProvider的PopulateDictionary方法，
                //將debug訊息自動加載到dictionary中。
                infoProvider.PopulateDictionary(dictionary);

                log.ExtendedProperties = dictionary;
            }
        }
    }
}
