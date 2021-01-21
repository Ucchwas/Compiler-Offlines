#include<string.h>
#include<string>
#ifndef SYMBOLINFO_H_INCLUDED
#define SYMBOLINFO_H_INCLUDED

using namespace std;

class SymbolInfo{
       
    public:
	string type;
        string name;
        string code;
        SymbolInfo *next;


        SymbolInfo(){
            name="";
            type="";
            code="";
        }
        SymbolInfo(string symbol, string type){
            this->name=symbol;
            this->type=type;
            code="";
        }
        SymbolInfo(char *symbol, char *type){
            this->name=string(symbol);
            this->type= string(type);
            code="";
        }

        SymbolInfo(const SymbolInfo *sym){
         	name=sym->name;
         	type=sym->type;
         	code=sym->code;
        }

        string getSymbol(){return name;}
        string getType(){return type;}

        void setSymbol(char *symbol){
            this->name=string(symbol);
        }

        void setType(char *type){
            this->type= string(type);
        }

        void setSymbol(string symbol){
            this->name=symbol;
        }
        void setType(string type){
            this->type=type;
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

	SymbolInfo* LU(string name)
        { int k=0;
            int hash_val=Hash(name);

            SymbolInfo* entry= htable[hash_val]->next;

            int p=0;

            while(entry!=NULL)
            {
                if(entry->name==name)
                {
                    k=1;
                   
                    return entry;

                }
                p++;
                entry=entry->next;
            }

            if(k==0) {
                    
                    return NULL;
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
    SymbolInfo* Look(string name)
         {
             SymbolInfo* temp= st->LU(name);
             return temp;
         }

         SymbolInfo* LookAll(string name)
         {
             ScopeTable* run=st;
             SymbolInfo* temp;

             while(run->parentScope!=NULL)
             {
                 temp=run->LU(name);
                 if(temp) return temp;

                 run=run->parentScope;
             }
             if(run->parentScope==NULL) {return run->LU(name);}

         }

};

#endif
