# Sales Analysis Using SQL
<H3 align='center'> QUESTION TO ANSWER </h3>
1.	Member vs Non-Member Sales, and Sales Contribution Monthly and Quarterly<BR>
2.	Profile wise Quarterly Sales, Quantity, Discount, Avg Sales/Customer, Avg Spend/Visit, Avg Price/Product and Avg Discount/Customer<BR>
3.	Location wise Quarterly Sales and Customers Contribution<BR>
4.	Top performing Product Groups across multiple Quarters by Sales<BR>
5.	Top 5 Product Types in the year by # of Customers shopped<BR>
6.	% Multimers (Customers who came more than once); and average Repurchase Gap between First and Last Transaction<BR>
7.	Month wise Performance of the brand<BR>

<hr>
<h3 align='center'>Tables used in analysis</h3>
we have 3 tables  – Sales, Products and Customers for the Client – ‘Trailblazers, Inc.’

<h4>Sales Table</h4>
Has 1 Year Transactional Data on a CustomerId, BasketId and SKU level
TransactionTypeId 4 and 6 signify returns which need to be subtracted from overall sales /quantity while calculating any numbers
CustomerId where not present signifies a Non Member Cash Transaction, such Customers are called ‘Non Members’
Customers with a CustomerId are called ‘Members’
The company has 5 Offline Flagship Stores, Pop-Up Stores and also sells on Online Channel, which is available as LocationName

<h4>Products Table</h4>
Contains info on 3 levels, the heirarchy being SKU < ProductType < ProductGroup

<h4>Customers Table</h4>
Contains CustomerId, Profile, State, Email Data, and Customer’s Latitude and Longitude
Profile signifies Customer’s Demographic attributes, and can be NULL for certain customers if we do not have their information
State Information signifies where they live, and can be NULL
Has_Email signifies whether the Customer has a valid Email or not, 1 signifies presence of a valid Email
Latitude and Longitude Information can help put the customer in a map, but this info can be NULL too
