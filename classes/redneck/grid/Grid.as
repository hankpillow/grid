/**
* @author igor almeida
* @version 2.1
*	
*	CHANGE LOG 2.1 (01.11.2011):
* --------------------------------------
*	+ appendRow
*	+ appendColumn
*	+ detachRow
*	+ detachColumn
*	+ dispose
*	- fill removed. see iterator.forEach
*
* */
package redneck.grid
{
	import flash.errors.IllegalOperationError;
	public class Grid
	{
		//@private
		private var _matrix : Array
		private var _iterator : GridIterator
		private var _height: int;
		private var _width : int;

		//getters
		public function get width():int{return  _width; }
		public function get height():int{return  _height; }
		public function get size():int {return _width*_height }
		public function get iterator():GridIterator { return _iterator }

		/**
		* @param	p_columns	uint
		* @param	p_lines		uint 
		* */
		public function Grid( p_columns:uint = 1, p_lines:uint = 1 ) : void
		{
			_width = Math.max(p_columns,1);
			_height = Math.max(p_lines,1);
			_iterator = new GridIterator( this );
			reset( );
		}

		/**
		* Append <code>value</code> rows into the grid
		* Grid indexes are Array like so, the first row/column is index 0
		* 
		* @see detachRow
		* 
		* @param value	int		the ammount of rows to add into.
		* @param index	uint	the row index to put the new row in
		* 
		* @return Grid
		**/
		public function appendRow(value:int=1, index:uint=int.MAX_VALUE):Grid
		{
			value = Math.max(0,value);

			if (value===0){
				// tsc tsc tsc
				return this
			}

			index = Math.min(_height,index);
			_height += value;
			const chunk : Array = new Array(_width*value);

			switch (index){
				case 0:
					_matrix = chunk.concat(_matrix);
					break;
				case size:
					_matrix= _matrix.concat(chunk);
					break;
				default:
					const left : Array = _matrix.splice(0,_width*index);
					const right : Array = _matrix.splice(0,_width*index);
					_matrix = left.concat(chunk,right,_matrix);
			}
			return this;
		}

		/**
		* Append <code>value</code> columns into the grid
		* Grid indexes are Array like so, the first row/column is index 0
		* 
		* @see detachRow
		* 
		* @param value	int		the ammount of rows to add into.
		* @param index	uint	the row index to put the new row in
		* 
		* @return Grid
		**/
		public function appendColumn(value:int=1,index:uint=int.MAX_VALUE):Grid
		{
			value = Math.max(0,value);

			if (value===0){
				// tsc tsc tsc
				return this
			}

			index = Math.min( _width,index );
			_width += value;

			var rows : int = _height;
			var row : int = 0;
			var col : uint = index;
			const chunk : Array = new Array(value);
			while(row<rows){
				var left : Array
				if (col===0 && row===0){
					_matrix = chunk.concat(_matrix);
				}
				else{
					left = _matrix.splice( 0, col-1+chunk.length );
					_matrix = left.concat(chunk,_matrix);
				}
				row++;
				col +=_width;
			}
			return this
		}

		/**
		* Detaches <code>value</code> rows from the grid
		* Take care when detaching rows, the data inside these cells will be lost.
		* 
		* @see appendRow
		* 
		* @param value	int		the ammount of rows to remove from.
		* @param index	uint	row index to start chopping off.
		* 
		* @return Grid
		**/
		public function detachRow(value:int=1, index:uint=int.MAX_VALUE ):Grid
		{
			value = Math.max(0,value);
			index = Math.min(index,_height-1);

			if (value === 0){
				// tsc tsc tsc
				return this;
			}

			if (value>=_height){
				throw new IllegalOperationError("If you want remove all rows, just call the dispose method.");
				return this;
			}

			if (_height-index<value){
				throw new IllegalOperationError("You cant remove this ammount of rows or the supplied index + number of rows to remove is bigger than the number of existent rows.");
				return this;
			}

			_height-=value;

			if (index>0){
				const left : Array = _matrix.splice(0,_width*index);
				const chunk : Array = _matrix.splice(0,_width*value);
				_matrix = left.concat(_matrix);
			}

			return this
		}

		/**
		* Detaches <code>value</code> columns from the grid
		* Take care when detaching rows, the data inside these cells will be lost.
		* 
		* @see appendRow
		* 
		* @param value	int		the ammount of columns to be removed.
		* @param index	uint	column index to start chopping off.
		* 
		* @return Grid
		**/
		public function detachColumn(value:int=1, index:uint=int.MAX_VALUE):Grid
		{
			value = Math.max(0,value);
			index = Math.min(index,_width-1);

			if (value === 0){
				// tsc tsc tsc
				return this;
			}

			if (value>=_width){
				throw new IllegalOperationError("If you want remove all columns, just call the dispose method.");
				return this;
			}

			if (_width-index<value){
				throw new IllegalOperationError("You cant remove this ammount of columns or the supplied index + number of columns to remove is bigger than the number of existent columns.");
				return this;
			}

			_width -= value;

			var rows : int = _height;
			var row : int = 0;
			var col : uint = index;

			while(row<rows){
				var left : Array
				_matrix.splice(col, value);
				row++;
				col +=_width;
			}

			return this;
		}

		/**
		* resetup grid and reset iterator
		* @return Grid
		**/
		public function reset():Grid
		{
			_matrix = new Array( size-1 );
			iterator.reset();
			return this;
		}

		/**
		* @param p_index
		* @return Pointer
		**/
		public function indexToPointer(p_index:int):Pointer
		{
			if (hasIndex(p_index)){
				const pointer : Pointer = new Pointer;
					pointer.r = int(p_index/width);
					pointer.c = p_index-width*pointer.r;
				return pointer;
			}
			return null
		}

		/**
		* @param p_pointer	Pointer
		* @return int
		**/
		public function pointerToIndex( p_pointer:Pointer ):int
		{
			return p_pointer.c+width*p_pointer.r;
		}

		/**
		* @return Boolean
		**/
		public function hasIndex( p_index:int ):Boolean
		{
			return p_index>=0 && p_index<size;
		}

		/**
		* @return Boolean
		**/
		public function hasPointer(p_pointer:Pointer):Boolean
		{
			return hasIndex( pointerToIndex(p_pointer) );
		}

		/**
		* Adds <code>value</code> into <code>index</code>
		* 
		* @see hasIndex
		* @see fill
		* 
		* @param value	*
		* @param index	uint
		* 
		* @return Boolean
		**/
		public function add( value:* , index:int ) : Boolean
		{
			if ( hasIndex(index) ){
				_matrix[ index ] = value;
				return true;
			}
			return false;
		}

		/**
		* Return the grid's value for a given index
		* 
		* @see valueFromPointer
		* @see pointerToIndex
		* 
		* @return *
		**/
		public function get( index:int ) : *
		{
			if (hasIndex(index)){
				return _matrix[ index ];
			}
			return null;
		}

		/**
		* return the grid's value for a given pointer
		* 
		* @see get
		* 
		* @return *
		**/
		public function valueFromPointer(pointer:Pointer):*
		{
			return get(pointerToIndex(pointer));
		}

		/**
		* Return an array representing row <code>p_row</code>
		* 
		* @param p_row	uint	row index
		* 
		* @return Array
		**/
		public function getRow( p_row:uint=0 ) : Array
		{
			var result : Array = new Array;
			var index : int = width*p_row;
			const end : int = index+width;
			while (index<end)
			{
				if (hasIndex(index)){
					result.push(get(index));
				}
				index++
			}
			return result;
		}
		
		/**
		* Return an array representing column <code>p_column</code>
		* 
		* @param p_column	uint	column index
		* 
		* @return Array
		**/
		public function getColumn( p_column:uint=0 ):Array
		{
			var result : Array = new Array;
			var counter : int;
			var index : int;
			while ( counter<size)
			{
				index = int(counter%width);
				if (index==p_column && hasIndex(counter)){
					result.push(get(counter));
				}
				counter++;
			}
			return result;
		}

		/**
		* Just for debug.
		* 
		* @return Grid
		**/
		public function dump():Grid
		{
			trace("+Grid("+width+","+height+")");
			var counter : int = 0;
			var row : String = "";
			while ( counter<size){
				row += "|"+get(counter);
				counter++;
				if (counter%width==0){
					trace(row+"|");
					row = "";
				}
			}
			return this;
		}

		/**
		* disposes the main _matrix.
		**/
		public function dispose():void{
			_matrix.length = 0
			_matrix = null;
		}
	}
}