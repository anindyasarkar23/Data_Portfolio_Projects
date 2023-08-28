
--Displaying whole Dataset

SELECT * FROM NASHVILLE_HOUSING

--convert saledate to DATE from DATE TIME by creating a new column


ALTER TABLE NASHVILLE_HOUSING
ADD SaleDateConverted Date

UPDATE NASHVILLE_HOUSING
SET SaleDateConverted=CONVERT(DATE,SaleDate)

--Populate Property Address (Filling in the NULL values by finding pattern from parcel ID)

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NASHVILLE_HOUSING a
join NASHVILLE_HOUSING b
on b.ParcelID=a.ParcelID and b.[UniqueID ]<>a.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NASHVILLE_HOUSING a
join NASHVILLE_HOUSING b
on b.ParcelID=a.ParcelID and b.[UniqueID ]<>a.[UniqueID ]
where a.PropertyAddress is null



--Split Address into Address and City

--Address
alter table nashville_housing
add PropertyAddressSplit Nvarchar(255)

update NASHVILLE_HOUSING
set PropertyAddressSplit=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

--City
alter table nashville_housing
add PropertyAddressCity Nvarchar(255)

update NASHVILLE_HOUSING
set PropertyAddressCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


--Split Owner Address

alter table nashville_housing
add OwnerSplitAddress Nvarchar(255)

Update NASHVILLE_HOUSING
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


alter table nashville_housing
add OwnerSplitCity Nvarchar(255)

Update NASHVILLE_HOUSING
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table nashville_housing
add OwnerSplitState Nvarchar(255)

Update NASHVILLE_HOUSING
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change Y & N to Yes and No in "Sold as Vacant" field


update NASHVILLE_HOUSING
set SoldAsVacant=Case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
End

--Displaying Duplicates

with RowNumCTE AS(
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference
			 order by UniqueID)row_num
from NASHVILLE_HOUSING)

select * from RowNumCTE
where row_num>1


--Remove Duplicates (Using Window Function to find duplicate values)

with RowNumCTE AS(
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference
			 order by UniqueID)row_num
from NASHVILLE_HOUSING)

Delete from RowNumCTE
where row_num>1

--Remove Unused Column


alter table nashville_housing 
drop column PropertyAddress,TaxDistrict,OwnerAddress,SaleDate



