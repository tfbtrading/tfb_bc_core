query 50108 "TFB Item Ledger Entries"
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;
    Caption = 'Item Ledger Entries';


    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(EntryNo; "Entry No.")
            {
            }
            column(EntryType; "Entry Type")
            {
            }
            column(DocumentType; "Document Type")
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(ExternalDocumentNo; "External Document No.")
            {
            }
            column(DocumentLineNo; "Document Line No.")
            {
            }



            column(ItemNo; "Item No.")
            {
            }
            column(ItemReferenceNo; "Item Reference No.")
            {
            }
            column(LotNo; "Lot No.")
            {
            }
            column(LocationCode; "Location Code")
            {
            }
            column(DropShipment; "Drop Shipment")
            {
            }
            column(Nonstock; Nonstock)
            {
            }
            column(Open; Open)
            {
            }
            column(OrderLineNo; "Order Line No.")
            {
            }
            column(OrderNo; "Order No.")
            {
            }
            column(OrderType; "Order Type")
            {
            }
            column(OutofStockSubstitution; "Out-of-Stock Substitution")
            {
            }
            column(Positive; Positive)
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(PurchasingCode; "Purchasing Code")
            {
            }
            column(PurchaseAmountActual; "Purchase Amount (Actual)")
            {
            }
            column(PurchaseAmountExpected; "Purchase Amount (Expected)")
            {
            }
            column(Quantity; Quantity)
            {
            }
            column(RemainingQuantity; "Remaining Quantity")
            {
            }
            column(SourceNo; "Source No.")
            {
            }
            column(SourceType; "Source Type")
            {
            }
            column(SystemCreatedAt; SystemCreatedAt)
            {
            }
            column(SystemModifiedAt; SystemModifiedAt)
            {
            }
            column(SystemId; SystemId)
            {
            }
            column(UnitofMeasureCode; "Unit of Measure Code")
            {
            }
            column(VariantCode; "Variant Code")
            {
            }
            column(ItemTracking; "Item Tracking")
            {
            }
            column(ExpirationDate; "Expiration Date")
            {
            }


        }
    }


}