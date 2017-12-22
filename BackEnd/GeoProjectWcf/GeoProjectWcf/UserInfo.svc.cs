using GeoEntity;
using GeoLib;
using GeoProjectWcf.Code;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace GeoProjectWcf
{
    public class UserInfo : IUserInfo
    {
        /// <summary>
        /// For Testing
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public string loginGet(string username)
        {
            Actions action = new Actions();
            return action.GetCoord(username);
        }

        public int login(string username, string password, int issignup)
        {
            Users user = new Users();
            return user.login(username, password, issignup);
        }

        public int SetFavorite(string username, string[][] idList, int isAdd)
        {
            Users user = new Users();
            return user.SetFavorite(username, idList, isAdd);
        }


        public string[][] GetFavorite(string username)
        {
            Users user = new Users();
            return user.GetFavorite(username);
        }

        public string GetCoord(string id)
        {
            Actions action = new Actions();
            return action.GetCoord(id);
        }

        /*
        public void SetFavorites(FavoriteList composite)
        {
        }

        public CompositeType GetDataUsingDataContract(CompositeType composite)
        {
            if (composite == null)
            {
                throw new ArgumentNullException("composite");
            }
            if (composite.BoolValue)
            {
                composite.StringValue += "Suffix";
            }
            return composite;
        }*/
    }
}
