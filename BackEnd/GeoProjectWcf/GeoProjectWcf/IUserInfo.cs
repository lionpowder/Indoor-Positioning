using GeoEntity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace GeoProjectWcf
{
    // 注意: 您可以使用 [重構] 功能表上的 [重新命名] 命令同時變更程式碼和組態檔中的介面名稱 "IService1"。
    [ServiceContract]
    public interface IUserInfo
    {
        [OperationContract]
        [WebInvoke(Method = "GET", RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "login/{username}")]
        string loginGet(string username);

        [OperationContract]
        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "login")]
        int login(string username, string password, int issignup);

        [OperationContract]
        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "GetCoord")]
        string GetCoord(string id);

        [OperationContract]
        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "SetFavorite")]
        int SetFavorite(string username, string[][] idList, int isAdd);

        [OperationContract]
        [WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
            BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "GetFavorite")]
        string[][] GetFavorite(string username);

    //    [OperationContract]
    //    [WebInvoke(RequestFormat = WebMessageFormat.Xml, ResponseFormat = WebMessageFormat.Xml,
    //BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "GetDataUsingDataContract")]
    //    CompositeType GetDataUsingDataContract(CompositeType composite);

    //    [OperationContract]
    //    [WebInvoke(RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json,
    //BodyStyle = WebMessageBodyStyle.WrappedRequest, UriTemplate = "SetFavorites")]
    //    void SetFavorites(FavoriteList composite);
    }

    /*
    [DataContract]
    public class FavoriteList
    {
        string id = "";
        string name = "";

        [DataMember]
        public string Id
        {
            get { return id; }
            set { id = value; }
        }

        [DataMember]
        public string Name
        {
            get {return name;}
            set { name = value; }

        }
    }


    //使用下列範例中所示的資料合約，新增複合型別至服務作業。
    [DataContract]
    public class CompositeType
    {
        bool boolValue = true;
        string stringValue = "Hello ";

        [DataMember]
        public bool BoolValue
        {
            get { return boolValue; }
            set { boolValue = value; }
        }

        [DataMember]
        public string StringValue
        {
            get { return stringValue; }
            set { stringValue = value; }
        }
    }*/
}
