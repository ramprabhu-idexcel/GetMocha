<?php
/**
 * Reusable code for modal dialogs.
 */
function injectFileModal() {
?>
	<div id="add-file-modal" class="modal">
		<a href="#" class="btn close-btn ir"><span>Close</span></a>
		<form action="#" class="padder">
			<div class="group">
				<label>Title</label>
				<?php injectTextInput(); ?>
			</div>
			<div class="group">
				<label>Tags <span class="instr">(E.g. accepted, rejected, pending)</span></label>
				<?php injectTextInput(); ?>
			</div>
			<div class="group choose-col">
				<a href="#" class="btn choose-files-btn ir"><span>Choose File(s)</span></a>
				<span class="filename">accepted.psd</span>
			</div>
			<div class="group submit-col">
				<input type="submit" class="btn" value="Add Task" />
			</div>
		</form>
	</div>
<?php
}
function injectCalendar() {
?>
	<div class="calendar f-lft">
		<div class="month-nav">
			<a class="icon icon-left ir" href="#"><span>&lsaquo;&lsaquo;</span></a>
			<a class="month-text" href="#">September</a>
			<a class="icon icon-right ir" href="#"><span>&rsaquo;&rsaquo;</span></a>
		</div>
		<table border="0" cellpadding="0" cellspacing="8">
			<thead>
				<tr>
					<th>S</th>
					<th>M</th>
					<th>T</th>
					<th>W</th>
					<th>T</th>
					<th>F</th>
					<th>S</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td class="dim"><a href="#">29</a></td>
					<td class="dim"><a href="#">30</a></td>
					<td class="dim"><a href="#">31</a></td>
					<td><a href="#">1</a></td>
					<td><a href="#">2</a></td>
					<td class="selected today"><a href="#">3</a></td>
					<td><a href="#">4</a></td>
				</tr>
				<tr>
					<td><a href="#">5</a></td>
					<td><a href="#">6</a></td>
					<td class="flag"><a href="#">7</a></td>
					<td><a href="#">8</a></td>
					<td><a href="#">9</a></td>
					<td><a href="#">10</a></td>
					<td><a href="#">11</a></td>
				</tr>
				<tr>
					<td><a href="#">12</a></td>
					<td><a href="#">13</a></td>
					<td><a href="#">14</a></td>
					<td><a href="#">15</a></td>
					<td><a href="#">16</a></td>
					<td><a href="#">17</a></td>
					<td><a href="#">18</a></td>
				</tr>
				<tr>
					<td><a href="#">19</a></td>
					<td><a href="#">20</a></td>
					<td><a href="#">21</a></td>
					<td><a href="#">22</a></td>
					<td class="flag"><a href="#">23</a></td>
					<td><a href="#">24</a></td>
					<td><a href="#">25</a></td>
				</tr>
				<tr>
					<td><a href="#">26</a></td>
					<td><a href="#">27</a></td>
					<td><a href="#">28</a></td>
					<td><a href="#">29</a></td>
					<td><a href="#">30</a></td>
					<td class="dim"><a href="#">1</a></td>
					<td class="dim"><a href="#">2</a></td>
				</tr>
			</tbody>
		</table>
	</div>
<?php
}
?>
