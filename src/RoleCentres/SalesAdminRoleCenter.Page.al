
page 50109 "TFB Sales Admin Role Center"
{
    PageType = RoleCenter;
    Caption = 'Sales Admin Role Center';
    ApplicationArea = All;


    layout
    {
        area(RoleCenter)
        {

            part(Activities; "TFB Sales Admin Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(LastRecords; "DYCE LastRecordsPart")
            {
                Visible = true;

            }
            part(FavouriteRecords; "DYCE FavoriteRecordsPart")
            {
                Visible = true;
            }
            part("Help And Chart Wrapper"; "Help And Chart Wrapper")
            {
                ApplicationArea = Basic, Suite;
            }

            part("Power BI Report Spinner Part"; "Power BI Report Spinner Part")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action("Sales Quote")
            {
                RunPageMode = Create;
                Caption = 'Sales Quote';
                ToolTip = 'Open Sales Quote';
                Image = New;
                RunObject = page "Sales Quote";
                ApplicationArea = Basic, Suite;
            }
            action("Sales Order")
            {
                RunPageMode = Create;
                Caption = 'Sales Order';
                ToolTip = 'Open Sales Order';
                Image = New;
                RunObject = page "Sales Order";
                ApplicationArea = Basic, Suite;
            }
        }
        area(Processing)
        {

            action(Requisition)
            {

                Caption = 'Requisition Worksheet';
                ToolTip = 'Open Requisition Worksheet';
                Image = Worksheet;
                RunObject = page "Req. Worksheet";
            }
        }
        area(Reporting)
        {


        }
        area(Embedding)
        {

            action(Contacts)
            {
                RunPageMode = View;
                Caption = 'Contacts';
                ToolTip = 'Open Contacts List';
                Image = ContactPerson;
                RunObject = page "Contact List";
                ApplicationArea = Basic, Suite;
            }
            action(Customers)
            {
                RunPageMode = View;
                Caption = 'Customers';
                ToolTip = 'Open Customer List';
                Image = CustomerList;
                RunObject = page "Customer List";
                ApplicationArea = Basic, Suite;
            }
            action(Vendors)
            {
                RunPageMode = View;
                Caption = 'Vendors';
                ToolTip = 'Open Vendor List';
                Image = CustomerList;
                RunObject = page "Vendor List";
                ApplicationArea = Basic, Suite;
            }
            action(Items)
            {
                RunPageMode = View;
                Caption = 'Items';
                ToolTip = 'Open Item List';
                Image = CustomerList;
                RunObject = page "Item List";
                ApplicationArea = Basic, Suite;
            }
            action(QualityCertifications)
            {
                RunPageMode = View;
                Caption = 'Quality Certifications';
                ToolTip = 'Open Quality Certification List';
                Image = CustomerList;
                RunObject = page "TFB Vendor Certification List";
                ApplicationArea = Basic, Suite;
            }


        }
        area(Sections)
        {
            group(OngoingSales)
            {
                Caption = 'Open Sales & Purchases';
                action(SalesQuote)
                {
                    RunPageMode = View;
                    Caption = 'Sales quotes';
                    ToolTip = 'Open sales quote list';
                    Image = Quote;
                    RunObject = page "Sales Quotes";
                    ApplicationArea = Basic, Suite;
                }
                action(SalesOrder)
                {
                    RunPageMode = View;
                    Caption = 'Sales orders';
                    Tooltip = 'Open sales order list';
                    Image = OrderList;
                    RunObject = page "Sales Order List";
                    ApplicationArea = Basic, Suite;
                }
                action(WarehouseShipments)
                {
                    RunPageMode = View;
                    Caption = 'Warehouse shipments';
                    Tooltip = 'Open warehouse shipment list';
                    Image = OrderList;
                    RunObject = page "Warehouse Shipment List";
                    ApplicationArea = Basic, Suite;
                }
                action(PurchaseOrders)
                {
                    RunPageMode = View;
                    Caption = 'Purchase orders';
                    Tooltip = 'Open purchase order list';
                    Image = OrderList;
                    RunObject = page "Purchase Order List";
                    ApplicationArea = Basic, Suite;
                }
                action(Containers)
                {
                    RunPageMode = View;
                    Caption = 'Inbound Shipments';
                    Tooltip = 'Open inbound shipments';
                    Image = Shipment;
                    RunObject = page "TFB Container Entry List";
                    ApplicationArea = Basic, Suite;
                }

            }
            group(PstdSales)
            {
                Caption = 'Sales Shipments & Invoices';



                action(SalesShipments)
                {
                    RunPageMode = View;
                    Caption = 'Sales shipments';
                    Tooltip = 'Open sales shipment list';
                    Image = Shipment;
                    RunObject = page "Posted Sales Shipments";
                    ApplicationArea = Basic, Suite;
                }
                action(SalesInvoice)
                {
                    RunPageMode = View;
                    Caption = 'Sales invoices';
                    Tooltip = 'Open sales invoice list';
                    Image = Invoice;
                    RunObject = page "Posted Sales Invoices";
                    ApplicationArea = Basic, Suite;
                }

                action(SalesCredit)
                {
                    RunPageMode = View;
                    Caption = 'Sales credits';
                    Tooltip = 'Open sales credit list';
                    Image = NewWarehouseShipment;
                    RunObject = page "Posted Sales Credit Memos";
                    ApplicationArea = Basic, Suite;
                }

            }
            group(Quality)
            {
                Caption = 'Quality Documents';

                action(VendorCertificates)
                {
                    RunPageMode = View;
                    Caption = 'Vendor certificates';
                    Tooltip = 'Open vendor certificate list';
                    Image = Certificate;
                    RunObject = page "TFB Vendor Certification List";
                    ApplicationArea = Basic, Suite;
                }
                action(LotInfo)
                {
                    RunPageMode = View;
                    Caption = 'Lot info cards';
                    Tooltip = 'Open lot info card list';
                    Image = Certificate;
                    RunObject = page "Lot No. Information List";
                    ApplicationArea = Basic, Suite;
                }
                action(CertificateTypes)
                {
                    RunPageMode = View;
                    Caption = 'Certificate types';
                    Tooltip = 'Open certificate type lists';
                    Image = Certificate;
                    RunObject = page "TFB Certification Types";
                    ApplicationArea = Basic, Suite;
                }

            }

            group(Archive)
            {
                Caption = 'Archived Documents';

                action(SalesOrderAchive)
                {
                    RunPageMode = View;
                    Caption = 'Sales orders';
                    Tooltip = 'Open sales order archive list';
                    Image = Order;
                    RunObject = page "Sales Order Archives";
                    ApplicationArea = Basic, Suite;
                }

                action(PurchaseOrderArchive)
                {
                    RunPageMode = View;
                    Caption = 'Purchase orders';
                    Tooltip = 'Open purchase order archive list';
                    Image = Purchase;
                    RunObject = page "Purchase Order Archives";
                    ApplicationArea = Basic, Suite;
                }

                action(WarehouseShipmentArchive)
                {
                    RunPageMode = View;
                    Caption = 'Warehouse Shipments';
                    Tooltip = 'Open warehouse shipment archive list';
                    Image = NewWarehouseShipment;
                    RunObject = page "Posted Whse. Shipment List";
                    ApplicationArea = Basic, Suite;
                }
                action(CommunicationLog)
                {
                    RunPageMode = View;
                    Caption = 'Communication Log';
                    Tooltip = 'Open communication log achive list';
                    Image = Email;
                    RunObject = page "TFB Comm. Log Entries";
                    ApplicationArea = Basic, Suite;
                }


            }

        }
    }

}