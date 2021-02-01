pageextension 50452 "TFB Bus. Manag. Role Center" extends "Business Manager Role Center" //9902
{
    layout
    {
        addafter(Control9)
        {
            part("BankList"; "TFB Bank Account Part List")
            {
                ApplicationArea = All;
                Caption = 'Bank Accounts';

            }

        }
    }

    actions
    {
        addlast(Embedding)
        {
            action(TFBContacts)
            {
                Caption = 'Contacts';
                ApplicationArea = All;
                RunObject = Page "Contact List";
                RunPageMode = Edit;
                Image = ContactPerson;
                Tooltip = 'Opens contact list';
            }
        }
        addafter("Blanket Sales Orders")
        {
            action(TFBBrokerageContract)
            {
                RunObject = Page "TFB Brokerage Contract List";
                RunPageMode = view;
                Image = ContractPayment;
                Caption = 'Brokerage Contracts';
                ApplicationArea = All;
                Tooltip = 'Opens brokerage contracts';
            }
        }

        addbefore("Posted Sales Invoices")
        {
            action(TFBSalesShipment)
            {
                RunObject = Page "Posted Sales Shipments";
                RunPageMode = view;
                Image = SalesShipment;
                Caption = 'Posted Sales Shipments';
                RunPageView = sorting("Posting Date") order(descending);
                ApplicationArea = All;
                ToolTip = 'Opens sales shipment list';
            }
            action(TFBWarehouseShipment)
            {
                RunObject = Page "Posted Whse. Shipment List";
                RunPageMode = view;
                Image = SalesShipment;
                Caption = 'Posted Warehouse Shipments';
                RunPageView = sorting("Posting Date") order(descending);
                ApplicationArea = All;
                ToolTip = 'Opens posted warehouse shipment list';
            }
        }

        addafter("Blanket Purchase Orders")
        {
            action(TFBContainers)
            {
                RunObject = Page "TFB Container Entry List";
                RunPageMode = View;
                Image = Shipment;
                ApplicationArea = All;
                Caption = 'Containers';
                Tooltip = 'Opens list of containers';

            }
            action(TFBTransfers)
            {
                RunObject = Page "Transfer Orders";
                RunPageMode = View;
                Image = TransferOrder;
                ApplicationArea = All;
                Caption = 'Transfers';
                Tooltip = 'Opens list of transfer orders';
            }


        }

    }
}