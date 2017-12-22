using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GeoEntity
{
    public class GeoEntityService
    {
        protected GeoWcfEntities entities { get; set; }

        public GeoEntityService(GeoWcfEntities entities) 
        {
            this.entities = entities;
        }

        public int login(string username, string password, int issignup)
        {
            
            // isSignUp => check username exists => if not exist, save to database
            if (issignup == 1)
            {
                if (!entities.user.Any(a => a.username == username))
                {
                    user newUser = new user();
                    newUser.username = username;
                    newUser.psw = password;
                    entities.user.Add(newUser);
                    entities.SaveChanges();
                    return 1;
                }
            }
            else // SignIn => check both username and password
            {
                if (entities.user.Any(a => a.username == username))
                {
                    string dbPassword = entities.user.Where(a => a.username == username).Select(a => a.psw).FirstOrDefault();

                    return dbPassword == password ? 1 : 0;
                }
            }

            return 0;
        }

        public int SetFavorite(string username, string[][] idList, int isAdd)
        {
            List<favorite> selectedList = entities.favorite.Where(f => f.username == username).ToList();

            // isAdd add single record
            if (isAdd == 1)
            {
                if (!selectedList.Exists(f => f.locationName == idList[0][0]))
                {
                    favorite fav = new favorite();
                    fav.username = username;
                    fav.locationName = idList[0][0];
                    fav.location = idList[0][1];

                    entities.favorite.Add(fav);
                    entities.SaveChanges();

                    return 1;
                }                
            }
            else // is not add, delete current old record and add new
            {
                entities.favorite.RemoveRange(selectedList);
                entities.SaveChanges();

                List<favorite> newList = new List<favorite>();

                foreach (string[] ids in idList)
                {
                    favorite fav = new favorite();
                    fav.username = username;
                    fav.locationName = ids[0];
                    fav.location = ids[1];

                    newList.Add(fav);
                }

                entities.favorite.AddRange(newList);
                entities.SaveChanges();

                return 1;
            }

            return 0;
        }

        public Dictionary<string, string> GetFavorite(string username)
        {
            Dictionary<string, string> favorites = new Dictionary<string, string>();

            if (entities.favorite.Any(f => f.username == username))
            {
                List<favorite> selectedList = entities.favorite.Where(f => f.username == username).Select(f => f).ToList();

                favorites = selectedList.ToDictionary(f => f.locationName, f => f.location);
            }

            return favorites;
        }

        public string GetCoord(string id)
        {
            return entities.idCoord.Any(i => i.id == id) ? 
                entities.idCoord.Where(i => i.id == id).Select(i => i.coord).FirstOrDefault() : "not found";
        }
    }
}
