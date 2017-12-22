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
    public class Actions : BaseInteraction
    {
        public Actions() : base()
        {
        }

        public string GetCoord(string id)
        {
            base.Logging("GetCoord:" + id);
            return base.GetService().GetCoord(id);
        }
    }
}