using GeoEntity;
using GeoLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
namespace GeoProjectWcf.Code
{
    public class BaseInteraction
    {
        GeoEntityService service;

        public BaseInteraction()
        {
            service = new GeoEntityService(new GeoWcfEntities());
        }

        public GeoEntityService GetService()
        {
            return service;
        }

        public void Logging(string message)
        {
            CommonLogger.LogInformation(this.GetType(), message);
        }
    }
}