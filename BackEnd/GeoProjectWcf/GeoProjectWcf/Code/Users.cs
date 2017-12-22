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
    public class Users : BaseInteraction
    {
        public Users() : base()
        {
        }

        public string loginGet(string username)
        {
            base.Logging("GetCoord:" + username);
            return base.GetService().GetCoord(username);
        }

        public int login(string username, string password, int issignup)
        {
            base.Logging("login:" + username + "; signup:" + issignup);
            return base.GetService().login(username, password, issignup);
        }

        public int SetFavorite(string username, string[][] idList, int isAdd)
        {
            base.Logging("SetFavorite:username=" + username +
                "; isAdd=" + isAdd.ToString() + "; listFirst:" + idList[0][0]);

            if (idList == null)
                base.Logging("SetFavorite: idList == null");

            return base.GetService().SetFavorite(username, idList, isAdd);

        }


        public string[][] GetFavorite(string username)
        {
            base.Logging("GetFavorite:" + username);

            Dictionary<string, string> favorites = base.GetService().GetFavorite(username);

            return (
                from fav in favorites
                select new string[] {
                  fav.Key,
                  fav.Value
                }
             ).ToArray();

            /*
            StringBuilder sbJson = new StringBuilder();
            new JavaScriptSerializer().Serialize(dict, sbJson);
            return sbJson.ToString();*/
        }

    }
}