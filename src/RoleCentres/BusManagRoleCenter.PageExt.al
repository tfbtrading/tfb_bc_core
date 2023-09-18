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



        }
        addlast(sections)
        {
            group(Inventory)
            {
                action(TFBGenericItems)
                {
                    RunObject = Page "TFB Generic Items";
                    RunPageMode = View;
                    Image = ItemGroup;
                    Caption = 'Generic Items';
                    ToolTip = 'Opens list of generic items';
                    ApplicationArea = All;
                }
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
                    Caption = 'Transfer Orders';
                    Tooltip = 'Opens list of transfer orders';
                }
                action(TFBPostedTransferReceipt)
                {
                    ApplicationArea = All;
                    RunObject = Page "Posted Transfer Receipt";
                    RunPageMode = View;
                    Caption = 'Posted Transfer Receipts';
                    ToolTip = 'Opens list of transfer receipts';

                }
                action(TFBLotInfo)
                {
                    ApplicationArea = All;
                    RunObject = Page "Lot No. Information List";
                    RunPageMode = View;
                    Caption = 'Lot Info List';
                    ToolTip = 'Open pages with list of lot no info entry records';
                }
                action(TFBLotImages)
                {
                    ApplicationArea = All;
                    RunObject = Page "TFB Lot Images";
                    RunPageMode = View;
                    Caption = 'Lot Images';
                    ToolTip = 'Open list of lot images that have been taken';
                }
                action(TFBItemLedgerEntries)
                {
                    ApplicationArea = All;
                    RunObject = Page "Item Ledger Entries";
                    RunPageMode = View;
                    Caption = 'Item Ledger Entries';
                    ToolTip = 'Open list of all item ledger entries';
                }
                action(TFBItemJournals)
                {
                    ApplicationArea = All;
                    RunObject = Page "Item Journal";
                    RunPageMode = Edit;
                    Caption = 'Item Journals';
                    ToolTip = 'Open up item journals';
                }
                action(TFBItemReclassJournal)
                {
                    ApplicationArea = All;
                    RunObject = Page "Item Reclass. Journal";
                    RunPageMode = Edit;
                    Caption = 'Reclassification Journals';
                    ToolTip = 'Opens up item reclassification journals';
                }
            }

        }
        movefirst(Inventory; Items)
    }


}