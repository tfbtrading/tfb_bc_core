
page 50100 "TFB Ops Mgr Role Center"
{
    PageType = RoleCenter;
    Caption = 'Ops Mgr Role Center';

    layout
    {
        area(RoleCenter)
        {

            part(Activities; "TFB Ops Mgr Activities")
            {
                ApplicationArea = Basic, Suite;
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
            action("Purchase Order")
            {
                RunPageMode = Create;
                Caption = 'Purchase Order';
                ToolTip = 'Create new purchase order';
                Image = New;
                RunObject = page "Purchase Order";
                ApplicationArea = All;
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
                ApplicationArea = All;
            }
            group("Banking")
            {
                action("Payment Reconciliation Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reconcile Imported Payments';
                    Image = ApplyEntries;
                    RunObject = Codeunit "Pmt. Rec. Journals Launcher";
                    ToolTip = 'Reconcile your bank account by importing transactions and applying them, automatically or manually, to open customer ledger entries, open vendor ledger entries, or open bank account ledger entries.';
                }
                action("Import Bank Transactions")
                {
                    AccessByPermission = TableData "Bank Export/Import Setup" = IMD;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Bank Transactions...';
                    Image = Import;
                    RunObject = Codeunit "Pmt. Rec. Jnl. Import Trans.";
                    ToolTip = 'To start the process of reconciling new payments, import a bank feed or electronic file containing the related bank transactions.';
                }
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
                RunPageView = sorting(Name) order(ascending);
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
            action("Bank Accounts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Accounts';
                Image = BankAccount;
                RunObject = Page "Bank Account List";
                ToolTip = 'View or set up detailed information about your bank account, such as which currency to use, the format of bank files that you import and export as electronic payments, and the numbering of checks.';
            }
            action("Chart of Accounts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Chart of Accounts';
                RunObject = Page "Chart of Accounts";
                ToolTip = 'View or organize the general ledger accounts that store your financial data. All values from business transactions or internal adjustments end up in designated G/L accounts. Business Central includes a standard chart of accounts that is ready to support businesses in your country, but you can change the default accounts and add new ones.';
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
            action(AllContainers)
            {
                RunPageMode = View;
                Caption = 'Inbund Shipments';
                ToolTip = 'Open list of containers inbound';
                Image = Shipment;
                RunObject = page "TFB Container Entry List";
                ApplicationArea = All;
                RunPageView = sorting("Est. Arrival Date") order(descending);
            }



        }
        area(Sections)
        {
            group(OngoingSales)
            {
                Caption = 'Sales & Purchases';

                action("Blanket Sales Orders")
                {
                    ApplicationArea = Suite;
                    Caption = 'Blanket Sales Orders';
                    Image = Reminder;
                   
                    RunObject = Page "Blanket Sales Orders";
                    ToolTip = 'Use blanket sales orders as a framework for a long-term agreement between you and your customers to sell large quantities that are to be delivered in several smaller shipments over a certain period of time. Blanket orders often cover only one item with predetermined delivery dates. The main reason for using a blanket order rather than a sales order is that quantities entered on a blanket order do not affect item availability and thus can be used as a worksheet for monitoring, forecasting, and planning purposes..';
                }
                action(BrokerageContract)
                {
                    RunPageMode = View;
                    Caption = 'Brokerage Contracts';
                    Tooltip = 'Open brokerage contract list';
                    Image = OrderList;
                    RunObject = page "TFB Brokerage Contract List";
                    ApplicationArea = Basic, Suite;
                }
                action("Blanket Purchase Orders")
                {
                    ApplicationArea = Suite;
                    Caption = 'Blanket Purchase Orders';
                   
                    RunObject = Page "Blanket Purchase Orders";
                    ToolTip = 'Use blanket purchase orders as a framework for a long-term agreement between you and your vendors to buy large quantities that are to be delivered in several smaller shipments over a certain period of time. Blanket orders often cover only one item with predetermined delivery dates. The main reason for using a blanket order rather than a purchase order is that quantities entered on a blanket order do not affect item availability and thus can be used as a worksheet for monitoring, forecasting, and planning purposes.';
                }
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
                    Caption = 'Sales Orders';
                    Tooltip = 'Open sales order list';
                    Image = OrderList;
                    RunObject = page "Sales Order List";
                    ApplicationArea = Basic, Suite;
                }
                action(Brokerage)
                {
                    RunPageMode = View;
                    Caption = 'Brokerage Shipments';
                    Tooltip = 'Open brokerage shipment order list';
                    Image = OrderList;
                    RunObject = page "TFB Brokerage Shipment List";
                    RunPageView = where(Status = filter(<> "Supplier Invoiced"));
                    ApplicationArea = Basic, Suite;
                }
                action("Sales Return Orders")
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Sales Return Orders';
                    
                    RunObject = Page "Sales Return Order List";
                    ToolTip = 'Compensate your customers for incorrect or damaged items that you sent to them and received payment for. Sales return orders support warehouse documents for the item handling, the ability to return items from multiple sales documents with one return, and automatic creation of related sales credit memos or other return-related documents, such as a replacement sales order.';
                }
                action("Sales Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Credit Memos';
                  
                    RunObject = Page "Sales Credit Memos";
                    ToolTip = 'Revert the financial transactions involved when your customers want to cancel a purchase or return incorrect or damaged items that you sent to them and received payment for. To include the correct information, you can create the sales credit memo from the related posted sales invoice or you can create a new sales credit memo with copied invoice information. If you need more control of the sales return process, such as warehouse documents for the physical handling, use sales return orders, in which sales credit memos are integrated. Note: If an erroneous sale has not been paid yet, you can simply cancel the posted sales invoice to automatically revert the financial transaction.';
                }


                action(PurchaseOrders)
                {
                    RunPageMode = View;
                    Caption = 'Purchase Orders';
                    Tooltip = 'Open purchase order list';
                    Image = OrderList;
                    RunObject = page "Purchase Order List";
                    ApplicationArea = Basic, Suite;
                }

                action("<Page Purchase Credit Memos>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Credit Memos';
                 
                    RunObject = Page "Purchase Credit Memos";
                    ToolTip = 'Create purchase credit memos to mirror sales credit memos that vendors send to you for incorrect or damaged items that you have paid for and then returned to the vendor. If you need more control of the purchase return process, such as warehouse documents for the physical handling, use purchase return orders, in which purchase credit memos are integrated. Purchase credit memos can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature. Note: If you have not yet paid for an erroneous purchase, you can simply cancel the posted purchase invoice to automatically revert the financial transaction.';
                }
            }
            group(Logistics)
            {
                Caption = 'Logistics';
                action(Containers)
                {
                    RunPageMode = View;
                    Caption = 'Inbound Shipments';
                    Tooltip = 'Open inbound shipments';
                    Image = Shipment;
                    RunObject = page "TFB Container Entry List";
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
                action(Transfers)
                {
                    RunPageMode = View;
                    Caption = 'Transfer orders';
                    Tooltip = 'Open transfer order list';
                    Image = TransferOrder;
                    RunObject = page "Transfer Orders";
                    ApplicationArea = Basic, Suite;
                }

            }
            group(PstdSales)
            {
                Caption = 'Posted Sales Docs';

                action(PostedWarehouseShipments)
                {
                    RunPageMode = View;
                    Caption = 'Warehouse shipments';
                    Tooltip = 'Open warehouse shipment list';
                    Image = Shipment;
                    RunObject = page "Posted Whse. Shipment List";
                    ApplicationArea = Basic, Suite;
                }

                action(SalesShipments)
                {
                    RunPageMode = View;
                    Caption = 'Sales shipments';
                    Tooltip = 'Open sales shipment list';
                    Image = Shipment;
                    RunObject = page "Posted Sales Shipments";
                    ApplicationArea = Basic, Suite;
                }
                action(BrokerageShipped)
                {
                    RunPageMode = View;
                    Caption = 'Brokerage Shipments';
                    Tooltip = 'Invoiced brokerage shipment order list';
                    Image = OrderList;
                    RunObject = page "TFB Brokerage Shipment List";
                    RunPageView = where(Status = filter("Supplier Invoiced"));
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
                action("Posted Sales Return Receipts")
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Posted Sales Return Receipts';
                    RunObject = Page "Posted Return Receipts";
                    ToolTip = 'Open the list of posted sales return receipts.';
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
                action("Issued Reminders")
                {
                    ApplicationArea = Suite;
                    Caption = 'Issued Reminders';
                    Image = OrderReminder;
                    RunObject = Page "Issued Reminder List";
                    ToolTip = 'View the list of issued reminders.';
                }

            }
            group(Purchase)
            {
                Caption = 'Posted Purchase Docs';
                action("<Page Posted Purchase Invoices>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Open the list of posted purchase invoices.';
                }
                action("<Page Posted Purchase Credit Memos>")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Open the list of posted purchase credit memos.';
                }
                action("<Page Posted Purchase Receipts>")
                {
                    ApplicationArea = Suite;
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ToolTip = 'Open the list of posted purchase receipts.';
                }
                action("Posted Purchase Return Shipments")
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Posted Purchase Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                    ToolTip = 'Open the list of posted purchase return shipments.';
                }
            }
            group(Quality)
            {
                Caption = 'Quality Docs';

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
                Caption = 'Archived Docs';

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
                    RunObject = page "TFB Communication Entries";
                    ApplicationArea = Basic, Suite;
                }


            }

            group(Action39)
            {
                Caption = 'Finance';
                Image = Journals;
                ToolTip = 'Collect and make payments, prepare statements, and reconcile bank accounts.';

                action("Incoming Documents")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Incoming Documents';
                    Gesture = None;
                    
                    RunObject = Page "Incoming Documents";
                    ToolTip = 'Handle incoming documents, such as vendor invoices in PDF or as image files, that you can manually or automatically convert to document records, such as purchase invoices. The external files that represent incoming documents can be attached at any process stage, including to posted documents and to the resulting vendor, customer, and general ledger entries.';
                }
                action(GeneralJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Journals';
                    Image = Journal;
                 
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(false));
                    ToolTip = 'Post financial transactions directly to general ledger accounts and other accounts, such as bank, customer, vendor, and employee accounts. Posting with a general journal always creates entries on general ledger accounts. This is true even when, for example, you post a journal line to a customer account, because an entry is posted to a general ledger receivables account through a posting group.';
                }
                action(Action3)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chart of Accounts';
                  
                    RunObject = Page "Chart of Accounts";
                    ToolTip = 'View or organize the general ledger accounts that store your financial data. All values from business transactions or internal adjustments end up in designated G/L accounts. Business Central includes a standard chart of accounts that is ready to support businesses in your country, but you can change the default accounts and add new ones.';
                }

                action("G/L Budgets")
                {
                    ApplicationArea = Suite;
                    Caption = 'G/L Budgets';
                 
                    RunObject = Page "G/L Budget Names";
                    ToolTip = 'View summary information about the amount budgeted for each general ledger account in different time periods.';
                }

                action("Account Schedules")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Schedules';
                  
                    RunObject = Page "Account Schedule Names";
                    ToolTip = 'Get insight into the financial data stored in your chart of accounts. Account schedules analyze figures in G/L accounts, and compare general ledger entries with general ledger budget entries. For example, you can view the general ledger entries as percentages of the budget entries. Account schedules provide the data for core financial statements and views, such as the Cash Flow chart.';
                }

                action("Sales Budgets")
                {
                    ApplicationArea = SalesBudget;
                    Caption = 'Sales Budgets';
                
                    RunObject = Page "Budget Names Sales";
                    ToolTip = 'Enter item sales values of type amount, quantity, or cost for expected item sales in different time periods. You can create sales budgets by items, customers, customer groups, or other dimensions in your business. The resulting sales budgets can be reviewed here or they can be used in comparisons with actual sales data in sales analysis reports.';
                }
                action("Purchase Budgets")
                {
                    ApplicationArea = PurchaseBudget;
                    Caption = 'Purchase Budgets';
                  
                    RunObject = Page "Budget Names Purchase";
                    ToolTip = 'Enter item purchases values of type amount, quantity, or cost for expected item purchases in different time periods. You can create purchase budgets by items, vendors, vendor groups, or other dimensions in your business. The resulting purchase budgets can be reviewed here or they can be used in comparisons with actual purchases data in purchase analysis reports.';
                }
                action("Sales Analysis Reports")
                {
                    ApplicationArea = SalesAnalysis;
                    Caption = 'Sales Analysis Reports';
                    RunObject = Page "Analysis Report Sale";
                    ToolTip = 'Analyze the dynamics of your sales according to key sales performance indicators that you select, for example, sales turnover in both amounts and quantities, contribution margin, or progress of actual sales against the budget. You can also use the report to analyze your average sales prices and evaluate the sales performance of your sales force.';
                }
                action("Purchase Analysis Reports")
                {
                    ApplicationArea = PurchaseAnalysis;
                    Caption = 'Purchase Analysis Reports';
                    RunObject = Page "Analysis Report Purchase";
                    ToolTip = 'Analyze the dynamics of your purchase volumes. You can also use the report to analyze your vendors'' performance and purchase prices.';
                }
                action("Inventory Analysis Reports")
                {
                    ApplicationArea = InventoryAnalysis;
                    Caption = 'Inventory Analysis Reports';
                    RunObject = Page "Analysis Report Inventory";
                    ToolTip = 'Analyze the dynamics of your inventory according to key performance indicators that you select, for example inventory turnover. You can also use the report to analyze your inventory costs, in terms of direct and indirect costs, as well as the value and quantities of your different types of inventory.';
                }
                action("VAT Returns")
                {
                    ApplicationArea = VAT;
                    Caption = 'VAT Returns';
                    RunObject = Page "VAT Report List";
                    ToolTip = 'Prepare the VAT Return report so you can submit VAT amounts to a tax authority.';
                }
                action(Currencies)
                {
                    ApplicationArea = Suite;
                    Caption = 'Currencies';
                    Image = Currency;
                  
                    RunObject = Page Currencies;
                    ToolTip = 'View the different currencies that you trade in or update the exchange rates by getting the latest rates from an external service provider.';
                }
                action(Employees)
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Employees';
                 
                    RunObject = Page "Employee List";
                    ToolTip = 'View or modify employees'' details and related information, such as qualifications and pictures, or register and analyze employee absence. Keeping up-to-date records about your employees simplifies personnel tasks. For example, if an employee''s address changes, you register this on the employee card.';
                }
                action("VAT Statements")
                {
                    ApplicationArea = VAT;
                    Caption = 'VAT Statements';
                   
                    RunObject = Page "VAT Statement Names";
                    ToolTip = 'View a statement of posted VAT amounts, calculate your VAT settlement amount for a certain period, such as a quarter, and prepare to send the settlement to the tax authorities.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    
                    RunObject = Page Dimensions;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
            }
            group("Cash Management")
            {
                Caption = 'Cash Management';
                ToolTip = 'Process incoming and outgoing payments. Set up bank accounts and service connections for electronic banking.';
                action("Cash Flow Forecasts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Forecasts';
                    RunObject = Page "Cash Flow Forecast List";
                    ToolTip = 'Combine various financial data sources to find out when a cash surplus or deficit might happen or whether you should pay down debt, or borrow to meet upcoming expenses.';
                }
                action("Chart of Cash Flow Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chart of Cash Flow Accounts';
                    RunObject = Page "Chart of Cash Flow Accounts";
                    ToolTip = 'View a chart contain a graphical representation of one or more cash flow accounts and one or more cash flow setups for the included general ledger, purchase, sales, services, or fixed assets accounts.';
                }
                action("Cash Flow Manual Revenues")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Manual Revenues';
                    RunObject = Page "Cash Flow Manual Revenues";
                    ToolTip = 'Record manual revenues, such as rental income, interest from financial assets, or new private capital to be used in cash flow forecasting.';
                }
                action("Cash Flow Manual Expenses")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Manual Expenses';
                    RunObject = Page "Cash Flow Manual Expenses";
                    ToolTip = 'Record manual expenses, such as salaries, interest on credit, or planned investments to be used in cash flow forecasting.';
                }
                action(CashReceiptJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Cash Receipts"),
                                        Recurring = CONST(false));
                    ToolTip = 'Register received payments by manually applying them to the related customer, vendor, or bank ledger entries. Then, post the payments to G/L accounts and thereby close the related ledger entries.';
                }
                action(PaymentJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Journals';
                    Image = Journals;
                   
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Payments),
                                        Recurring = CONST(false));
                    ToolTip = 'Register payments to vendors. A payment journal is a type of general journal that is used to post outgoing payment transactions to G/L, bank, customer, vendor, employee, and fixed assets accounts. The Suggest Vendor Payments functions automatically fills the journal with payments that are due. When payments are posted, you can export the payments to a bank file for upload to your bank if your system is set up for electronic banking. You can also issue computer checks from the payment journal.';
                }
                action(Action23)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                  
                    RunObject = Page "Bank Account List";
                    ToolTip = 'View or set up detailed information about your bank account, such as which currency to use, the format of bank files that you import and export as electronic payments, and the numbering of checks.';
                }
                action("Bank Acc. Statements")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Acc. Statements';
                    Image = BankAccountStatement;
                  
                    RunObject = Page "Bank Account Statement List";
                    ToolTip = 'View statements for selected bank accounts. For each bank transaction, the report shows a description, an applied amount, a statement amount, and other information.';
                }
                action("Payment Recon. Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Recon. Journals';
                    Image = ApplyEntries;
                    
                    RunObject = Page "Pmt. Reconciliation Journals";
                    ToolTip = 'Reconcile unpaid documents automatically with their related bank transactions by importing a bank statement feed or file. In the payment reconciliation journal, incoming or outgoing payments on your bank are automatically, or semi-automatically, applied to their related open customer or vendor ledger entries. Any open bank account ledger entries related to the applied customer or vendor ledger entries will be closed when you choose the Post Payments and Reconcile Bank Account action. This means that the bank account is automatically reconciled for payments that you post with the journal.';
                }


                action(BankAccountReconciliations)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Account Reconciliations';
                    Image = BankAccountRec;
                   
                    RunObject = Page "Bank Acc. Reconciliation List";
                    ToolTip = 'Reconcile bank accounts in your system with bank statements received from your bank.';
                }
                action(Reminders)
                {
                    ApplicationArea = Suite;
                    Caption = 'Reminders';
                    Image = Reminder;
                    
                    RunObject = Page "Reminder List";
                    ToolTip = 'Remind customers about overdue amounts based on reminder terms and the related reminder levels. Each reminder level includes rules about when the reminder will be issued in relation to the invoice due date or the date of the previous reminder and whether interests are added. Reminders are integrated with finance charge memos, which are documents informing customers of interests or other money penalties for payment delays.';
                }
            }

        }
    }



}