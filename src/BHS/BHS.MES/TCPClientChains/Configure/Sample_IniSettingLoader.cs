#region Release Information
//
// =====================================================================================
// Copyright 2009, Xu Jian, All Rights Reserved.
// =====================================================================================
// FileName       IniSettingLoader.cs
// Revision:      1.0 -   02 Apr 2009, By Xu Jian
// =====================================================================================
//
#endregion

using System;
using System.IO;
using PALS.Configure;

namespace BHS.MES.TCPClientChains.Configure
{
    /// <summary>
    /// Loading application settings from XML file.
    /// </summary>
    public class IniSettingLoader : PALS.Configure.IConfigurationLoader
    {
        #region Class Field and Property Declarations

        // there are total ? INI configuration files required by ? application: 
        // File1.ini - application settings 
        // File2.ini - application telegram format definations.
        private const int DESIRED_NUMBER_OF_CFG_FILES = 1;

        // The name of current class 
        private static readonly string _className =
                    System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.ToString();
        // Create a logger for use in this class
        private static readonly log4net.ILog _logger =
                    log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        /// <summary>
        /// Parameter classes for storing application settings loaded from configuration file.
        /// </summary>
        public GlobalContext GlobalItems { get; set; }

        #endregion

        #region Class Constructor, Dispose, & Destructor

        /// <summary>
        /// Class constructor
        /// </summary>
        public IniSettingLoader()
        {
        }

        /// <summary>
        /// Class destructor
        /// </summary>
        ~IniSettingLoader()
        {
            Dispose(false);
        }

        /// <summary>
        /// Class method to be called by class wrapper for release resources explicitly.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
        }

        // Dispose(bool disposing) executes in two distinct scenarios. If disposing equals true, 
        // the method has been called directly or indirectly by a user's code. Managed and 
        // unmanaged resources can be disposed.
        // If disposing equals false, the method has been called by the runtime from inside the 
        // finalizer and you should not reference other objects. Only unmanaged resources can be disposed.
        private void Dispose(bool disposing)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";
            // Release managed & unmanaged resources...
            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object is being destroyed... <" + thisMethod + ">");
            }

            // Destory class level fields.
            if (GlobalItems != null) GlobalItems = null;

            if (disposing)
            {
                if (_logger.IsInfoEnabled)
                    _logger.Info("Class:[" + _className + "] object has been destroyed. <" + thisMethod + ">");
            }
        }

        #endregion


        #region IXmlLoder Members


        /// <summary>
        /// The actual implementation of IConfigurationLoader interface method LoadSettingFromConfigFile(). 
        /// This method will be invoked by AppConfigurator class.
        /// <para>
        /// Decode INI configuration file and load application settings shall be done by this method.
        /// </para>
        /// </summary>
        /// <param name="isReloading">
        /// If the parameter isReloading = true, the interface implemented LoadSettingFromConfigFile() 
        /// may raise a event after all settings have been reloaded successfully, to inform application 
        /// that the reloading setting has been done. So application can take the necessary actions
        /// to take effective of new settings.
        /// </param>
        /// <param name="cfgFiles">
        /// params type method argument, represents one or more configuration files.
        /// </param>
        void IConfigurationLoader.LoadSettingFromConfigFile(bool isReloading, params FileInfo[] cfgFiles)
        {
            string thisMethod = _className + "." + System.Reflection.MethodBase.GetCurrentMethod().Name + "()";

            // If the number of configuration files passed in is not same as the desired number, then throw exception.
            if (cfgFiles.Length != DESIRED_NUMBER_OF_CFG_FILES)
            {
                throw new Exception("The number of files (" + cfgFiles.Length +
                        ") passed to configuration loader is not desired number (" + DESIRED_NUMBER_OF_CFG_FILES + ").");
            }

            if (_logger.IsInfoEnabled)
                _logger.Info("Loading application settings... <" + thisMethod + ">");


            // Loading application settings from XML file...
            //...

            if (_logger.IsInfoEnabled)
                _logger.Info("Loading application settings is successed. <" + thisMethod + ">");
        }

        #endregion

    }
}
