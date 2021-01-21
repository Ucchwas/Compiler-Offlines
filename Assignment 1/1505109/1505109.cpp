#include<iostream>
#include<cstdio>

using namespace std;

class SymbolInfo{
public:
        string name;
        string type;

        SymbolInfo  *next;
       SymbolInfo(string name,string type){
                this->name=name;
                this->type=type;
                this->next=NULL;
       }
       SymbolInfo(){
                this->name="";
                this->type="";
                this->next=NULL;
       }
};

class ScopeTable{
    private:
        SymbolInfo **htable;

    public:
        int range;
        int scope_id;
         ScopeTable *parentScope;

        ScopeTable(int range,int id){
                this->range=range;
                this->scope_id=id;
                htable=new SymbolInfo *[range];
                for(int i=0;i<range;i++)
                    htable[i]=new SymbolInfo();
                this->parentScope=NULL;
        }
        ~ScopeTable(){
            for(int i=0;i<range;i++){
                SymbolInfo *data=htable[i];
                while(data!=NULL){
                    SymbolInfo *del=data;
                    delete del;
                    data=data->next;
                }
            }
            delete []htable;
        }
        int Hash(string name){
        /*   int p,q=0;
            for(int i=0;i<name.size();i++){
                p=(int)name[i];
               q=(q+p%range)%range;
            }
            return q;*/
        unsigned long hs = 0;
        for(int i = 0 ; i < name.size() ; i++)
        {
            hs = (name[i] + (hs<<16)+(hs<<6) ) - hs;
        }
        return hs%range;
       /* unsigned long hsh = 5381;

        for(int i =0 ; i< name.size() ; i++)
        {
            hsh = hsh*33 + int(name[i]);
        }
        return hsh%(name.size());*/
        }
        void Insert(string name,string type){
            int p=0,k;
            k=Hash(name);
            SymbolInfo *data;
            data=htable[k]->next;
            while(data!=NULL){
                if(data->name==name){
                    p=1;
                    cout<<"<"<<data->name<<","<<data->type<<"> "<<"already exists in current ScopeTable";
                    cout<<endl;
                    break;
                }
                data=data->next;
            }
            if(p==0){
                int hash_val,k=0;
                hash_val=Hash(name);
                data=htable[hash_val];
                while(data->next!=NULL){
                    k++;
                    data=data->next;
                }
                if(data->next==NULL)
                    data->next=new SymbolInfo(name,type);
                cout<<"Inserted in Scopetable#"<<scope_id<<" at position "<<hash_val<<" , "<<k;
                cout<<endl;
            }
        }
            void PA(){
                cout<<"Scopetable "<<scope_id<<endl;
                for(int i=0;i<range;i++){
                    SymbolInfo *data;
                    data=htable[i]->next;
                    cout<<i<<"-->  ";
                    while(data!=NULL){
                        cout<<"< "<<data->name<<" :  "<<data->type<<" >"<<" ";
                        data=data->next;
                    }
                    cout<<endl;
                }
            }
            void LU(string name){
                int p=0,k=0,hash_val;
                hash_val=Hash(name);
                SymbolInfo *data;
                data=htable[hash_val]->next;
                while(data!=NULL){
                    if(data->name==name){
                        p=1;
                        cout<<"Found inScopetable#"<<scope_id<<"at position: "<<hash_val<<" , "<<k;
                        cout<<endl;
                        break;
                    }
                    k++;
                    data=data->next;
                }
                if(p==0)
                    cout<<"Not Found"<<endl;
            }
            void Delete(string name){
                int p=0,k;
                k=Hash(name);
                SymbolInfo *data;
                data=htable[k]->next;
                while(data!=NULL){
                    if(data->name==name){
                        p=1;
                        break;
                    }
                    data=data->next;
                }
                if(p==1){
                    int hash_val,t=0;
                    hash_val=Hash(name);
                    SymbolInfo *temp;
                    SymbolInfo *head;
                    head=htable[hash_val];
                    while(head->next!=NULL){
                        if(head->next->name==name){
                            temp=head->next;
                            head->next=temp->next;
                            delete(temp);
                            cout<<"Found in ScopeTable# "<<scope_id<<"at position "<<hash_val<<", "<<t;
                            cout<<endl;
                            cout<<"Deleted entry at "<<hash_val<<", "<<t<<" from current ScopeTable";
                            cout<<endl;
                            break;
                        }
                        head=head->next;
                        t++;
                    }
                    if(p==0)
                        cout<<"Not found in the scope";
                }
            }
};

class SymbolTable{
public:
    int range;
    ScopeTable *st;
    SymbolTable(int range){
    this->range=range;
    st=new ScopeTable(range,1);
    }
    void Entry(){
        if(st!=NULL){
            ScopeTable *temp;
            temp=new ScopeTable(range,st->scope_id+1);
            temp->parentScope=st;
            st=temp;
            cout<<"new ScopeTable with id "<<st->scope_id<<" created";
            cout<<endl;
            }
        else{
            cout<<"No ScopeTable Found";
            cout<<endl;
        }
    }
    void  Exit(){
        ScopeTable *temp;
        temp=st;
        if(st!=NULL){
            st=st->parentScope;
            cout<<"ScopeTable with id "<<temp->scope_id<<" removed";
            cout<<endl;
            delete(temp);
        }
        else{
            cout<<"No ScopeTable Found";
            cout<<endl;
        }
    }
    void Insertnew(string name,string type){
        if(st!=NULL){
            st->Insert(name,type);
        }
        else{
            cout<<"No ScopeTable Found";
            cout<<endl;
        }
    }
    void Removenew(string name){
        if(st!=NULL)
            st->Delete(name);
        else{
            cout<<"No ScopeTable Found";
            cout<<endl;
        }
    }
    void Printnew(){
            if(st!=NULL)
                st->PA();
            else{
                cout<<"No ScopeTable Found";
                cout<<endl;
            }
    }
    void PrintAll(){
        if(st!=NULL){
            ScopeTable *all;
            all=st;
            while(all->parentScope!=NULL){
                all->PA();
                cout<<endl;
                all=all->parentScope;
            }
            if(all->parentScope==NULL)
            all->PA();
        }
        else{
            cout<<"No ScopeTable Found";
            cout<<endl;
        }
    }
    void LookUp(string name){
        if(st!=NULL){
            ScopeTable *all;
            all=st;
            while(all->parentScope!=NULL){
                all->LU(name);
                all=all->parentScope;
            }
            if(all->parentScope==NULL)
            all->LU(name);
        }
        else{
            cout<<"No ScopeTable Found";
            cout<<endl;
        }
    }
};

main(){
    int r;
    cin>>r;

    SymbolTable st(r);
    while(1){
        char ch;
        cin>>ch;
        if(ch=='S'){
            st.Entry();
        }
        if(ch=='E'){
            st.Exit();
        }
        if(ch=='I'){
            string name,type;
            cin>>name;
            cin>>type;
            st.Insertnew(name,type);
        }
        if(ch=='P'){
            char all;
            cin>>all;
            if(all=='A')
                st.PrintAll();
            if(all=='C')
                st.Printnew();
        }
        if(ch=='L'){
            string name;
            cin>>name;
            st.LookUp(name);
        }
        if(ch=='D'){
            string name;
            cin>>name;
            st.Removenew(name);
        }
    }
}
